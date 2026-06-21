using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Chat;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class ChatService : IChatService
{
    private readonly AppDbContext _context;

    public ChatService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<(ConversationDetailDto Conversation, bool IsNew)> CreateOrOpenConversationAsync(
        Guid listingId, Guid userId, CreateConversationRequest? request)
    {
        // Validate listing exists and is available for interaction
        var listing = await _context.Listings
            .Include(l => l.Owner)
            .Include(l => l.Images)
            .FirstOrDefaultAsync(l => l.Id == listingId);

        if (listing is null)
            throw new NotFoundException("Listing not found");

        if (listing.Status is ListingStatus.Draft or ListingStatus.Closed or ListingStatus.Hidden)
            throw new BusinessRuleViolationException(
                $"Cannot start a conversation on a listing that is {listing.Status.ToString().ToLower()}");

        // Cannot chat with yourself
        if (listing.OwnerId == userId)
            throw new BusinessRuleViolationException("You cannot start a conversation on your own listing");

        // Try to find existing conversation for this triplet
        var existing = await _context.Conversations
            .Include(c => c.Listing)
                .ThenInclude(l => l.Images)
            .Include(c => c.Owner)
            .Include(c => c.Requester)
            .FirstOrDefaultAsync(c =>
                c.ListingId == listingId &&
                c.OwnerId == listing.OwnerId &&
                c.RequesterId == userId);

        if (existing is not null)
        {
            var detail = MapToDetailDto(existing, existing.Listing, existing.Owner, existing.Requester);
            return (detail, false);
        }

        // Create new conversation
        var conversation = new Conversation
        {
            Id = Guid.NewGuid(),
            ListingId = listingId,
            OwnerId = listing.OwnerId,
            RequesterId = userId,
            CreatedAt = DateTime.UtcNow
        };

        string? lastMessageContent = null;

        // Send initial message if provided
        if (!string.IsNullOrWhiteSpace(request?.InitialMessage))
        {
            var initialMessage = new Message
            {
                Id = Guid.NewGuid(),
                ConversationId = conversation.Id,
                SenderId = userId,
                Content = request.InitialMessage.Trim(),
                Status = MessageStatus.Sent,
                CreatedAt = DateTime.UtcNow
            };

            _context.Messages.Add(initialMessage);
            conversation.LastMessageAt = initialMessage.CreatedAt;
            lastMessageContent = initialMessage.Content;
        }

        _context.Conversations.Add(conversation);

        // Notify the listing owner that someone wants to chat
        _context.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = listing.OwnerId,
            Type = NotificationType.Message,
            Title = "New conversation",
            Body = $"Someone wants to chat about your listing \"{listing.Title}\"",
            ReferenceId = conversation.Id,
            ReferenceType = "Conversation",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();

        var result = new ConversationDetailDto
        {
            Id = conversation.Id,
            ListingId = listing.Id,
            ListingTitle = listing.Title,
            ListingImageUrl = listing.Images.FirstOrDefault(i => i.IsCover)?.ImageUrl,
            OwnerId = listing.Owner.Id,
            OwnerName = listing.Owner.FullName,
            OwnerAvatarUrl = listing.Owner.AvatarUrl,
            RequesterId = userId,
            RequesterName = "", // Will be loaded below
            RequesterAvatarUrl = null,
            LastMessageContent = lastMessageContent,
            LastMessageSenderId = lastMessageContent is not null ? userId : null,
            LastMessageAt = conversation.LastMessageAt,
            CreatedAt = conversation.CreatedAt
        };

        // Load requester info
        var requester = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        result.RequesterName = requester?.FullName ?? "Unknown";
        result.RequesterAvatarUrl = requester?.AvatarUrl;

        return (result, true);
    }

    public async Task<PagedResponse<ConversationSummaryDto>> GetMyConversationsAsync(
        Guid userId, int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var query = _context.Conversations
            .Include(c => c.Listing)
                .ThenInclude(l => l.Images)
            .Include(c => c.Owner)
            .Include(c => c.Requester)
            .Where(c => c.OwnerId == userId || c.RequesterId == userId);

        var totalCount = await query.CountAsync();

        var conversations = await query
            .OrderByDescending(c => c.LastMessageAt ?? c.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        // Batch-load unread counts for all visible conversations
        var conversationIds = conversations.Select(c => c.Id).ToList();
        var unreadCounts = await _context.Messages
            .Where(m => conversationIds.Contains(m.ConversationId)
                        && m.Status == MessageStatus.Sent
                        && m.SenderId != userId)
            .GroupBy(m => m.ConversationId)
            .Select(g => new { ConversationId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.ConversationId, x => x.Count);

        var items = conversations.Select(c =>
        {
            var (otherUserId, otherUserName, otherUserAvatar) = c.OwnerId == userId
                ? (c.RequesterId, c.Requester.FullName, c.Requester.AvatarUrl)
                : (c.OwnerId, c.Owner.FullName, c.Owner.AvatarUrl);

            unreadCounts.TryGetValue(c.Id, out var unreadCount);

            return new ConversationSummaryDto
            {
                Id = c.Id,
                ListingId = c.ListingId,
                ListingTitle = c.Listing.Title,
                ListingImageUrl = c.Listing.Images.FirstOrDefault(i => i.IsCover)?.ImageUrl,
                OtherParticipantId = otherUserId,
                OtherParticipantName = otherUserName,
                OtherParticipantAvatarUrl = otherUserAvatar,
                LastMessageContent = null, // Will be loaded from last message if needed
                LastMessageSenderId = null,
                LastMessageAt = c.LastMessageAt,
                UnreadCount = unreadCount,
                CreatedAt = c.CreatedAt
            };
        }).ToList();

        // Batch-load last message content for all conversations
        if (conversationIds.Count > 0)
        {
            var lastMessages = await _context.Messages
                .Where(m => conversationIds.Contains(m.ConversationId))
                .GroupBy(m => m.ConversationId)
                .Select(g => g.OrderByDescending(m => m.CreatedAt).First())
                .ToListAsync();

            var lastMessageMap = lastMessages.ToDictionary(m => m.ConversationId);

            foreach (var item in items)
            {
                if (lastMessageMap.TryGetValue(item.Id, out var lastMsg))
                {
                    item.LastMessageContent = lastMsg.Content;
                    item.LastMessageSenderId = lastMsg.SenderId;
                }
            }
        }

        return new PagedResponse<ConversationSummaryDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        };
    }

    public async Task<ConversationDetailDto> GetConversationDetailAsync(Guid conversationId, Guid userId)
    {
        var conversation = await ValidateConversationAccessAsync(conversationId, userId);

        await _context.Entry(conversation).Reference(c => c.Listing).LoadAsync();
        await _context.Entry(conversation.Listing).Collection(l => l.Images).LoadAsync();
        await _context.Entry(conversation).Reference(c => c.Owner).LoadAsync();
        await _context.Entry(conversation).Reference(c => c.Requester).LoadAsync();

        return MapToDetailDto(conversation, conversation.Listing, conversation.Owner, conversation.Requester);
    }

    public async Task<PagedResponse<MessageDto>> GetMessagesAsync(
        Guid conversationId, Guid userId, int page, int pageSize)
    {
        await ValidateConversationAccessAsync(conversationId, userId);

        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var totalCount = await _context.Messages
            .Where(m => m.ConversationId == conversationId)
            .CountAsync();

        var messages = await _context.Messages
            .Include(m => m.Sender)
            .Where(m => m.ConversationId == conversationId)
            .OrderByDescending(m => m.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(m => new MessageDto
            {
                Id = m.Id,
                ConversationId = m.ConversationId,
                SenderId = m.SenderId,
                SenderName = m.Sender.FullName,
                SenderAvatarUrl = m.Sender.AvatarUrl,
                Content = m.Content,
                Status = m.Status.ToString(),
                ReadAt = m.ReadAt,
                CreatedAt = m.CreatedAt
            })
            .ToListAsync();

        return new PagedResponse<MessageDto>
        {
            Items = messages,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        };
    }

    public async Task<MessageDto> SendMessageAsync(Guid conversationId, Guid userId, string content)
    {
        var conversation = await ValidateConversationAccessAsync(conversationId, userId);

        if (string.IsNullOrWhiteSpace(content))
            throw new BusinessRuleViolationException("Message content cannot be empty");

        var message = new Message
        {
            Id = Guid.NewGuid(),
            ConversationId = conversationId,
            SenderId = userId,
            Content = content.Trim(),
            Status = MessageStatus.Sent,
            CreatedAt = DateTime.UtcNow
        };

        _context.Messages.Add(message);
        conversation.LastMessageAt = message.CreatedAt;

        // Notify the other participant
        var otherUserId = conversation.OwnerId == userId
            ? conversation.RequesterId
            : conversation.OwnerId;

        // Load sender name for notification body
        var sender = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);

        _context.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = otherUserId,
            Type = NotificationType.Message,
            Title = "New message",
            Body = $"You have a new message from {sender?.FullName ?? "someone"}",
            ReferenceId = conversationId,
            ReferenceType = "Conversation",
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();

        return new MessageDto
        {
            Id = message.Id,
            ConversationId = message.ConversationId,
            SenderId = message.SenderId,
            SenderName = sender?.FullName ?? "Unknown",
            SenderAvatarUrl = sender?.AvatarUrl,
            Content = message.Content,
            Status = message.Status.ToString(),
            ReadAt = null,
            CreatedAt = message.CreatedAt
        };
    }

    public async Task<int> MarkMessagesAsReadAsync(Guid conversationId, Guid userId)
    {
        var conversation = await ValidateConversationAccessAsync(conversationId, userId);

        var unreadMessages = await _context.Messages
            .Where(m => m.ConversationId == conversationId
                        && m.Status == MessageStatus.Sent
                        && m.SenderId != userId)
            .ToListAsync();

        if (unreadMessages.Count == 0)
            return 0;

        var now = DateTime.UtcNow;
        foreach (var msg in unreadMessages)
        {
            msg.Status = MessageStatus.Read;
            msg.ReadAt = now;
        }

        await _context.SaveChangesAsync();

        return unreadMessages.Count;
    }

    public async Task<ConversationSummaryDto> GetConversationSummaryAsync(Guid conversationId, Guid userId)
    {
        var conversation = await ValidateConversationAccessAsync(conversationId, userId);

        await _context.Entry(conversation).Reference(c => c.Listing).LoadAsync();
        await _context.Entry(conversation.Listing).Collection(l => l.Images).LoadAsync();
        await _context.Entry(conversation).Reference(c => c.Owner).LoadAsync();
        await _context.Entry(conversation).Reference(c => c.Requester).LoadAsync();

        var (otherUserId, otherUserName, otherUserAvatar) = conversation.OwnerId == userId
            ? (conversation.RequesterId, conversation.Requester.FullName, conversation.Requester.AvatarUrl)
            : (conversation.OwnerId, conversation.Owner.FullName, conversation.Owner.AvatarUrl);

        var unreadCount = await _context.Messages
            .CountAsync(m => m.ConversationId == conversationId
                             && m.Status == MessageStatus.Sent
                             && m.SenderId != userId);

        // Get last message content
        var lastMessage = await _context.Messages
            .Where(m => m.ConversationId == conversationId)
            .OrderByDescending(m => m.CreatedAt)
            .FirstOrDefaultAsync();

        return new ConversationSummaryDto
        {
            Id = conversation.Id,
            ListingId = conversation.ListingId,
            ListingTitle = conversation.Listing.Title,
            ListingImageUrl = conversation.Listing.Images.FirstOrDefault(i => i.IsCover)?.ImageUrl,
            OtherParticipantId = otherUserId,
            OtherParticipantName = otherUserName,
            OtherParticipantAvatarUrl = otherUserAvatar,
            LastMessageContent = lastMessage?.Content,
            LastMessageSenderId = lastMessage?.SenderId,
            LastMessageAt = conversation.LastMessageAt,
            UnreadCount = unreadCount,
            CreatedAt = conversation.CreatedAt
        };
    }

    // --- Private helpers ---

    /// <summary>
    /// Validates that the conversation exists and the user is a participant.
    /// Returns the conversation entity for reuse.
    /// </summary>
    private async Task<Conversation> ValidateConversationAccessAsync(Guid conversationId, Guid userId)
    {
        var conversation = await _context.Conversations
            .FirstOrDefaultAsync(c => c.Id == conversationId);

        if (conversation is null)
            throw new NotFoundException("Conversation not found");

        if (conversation.OwnerId != userId && conversation.RequesterId != userId)
            throw new ForbiddenException("You are not a participant in this conversation");

        return conversation;
    }

    private static ConversationDetailDto MapToDetailDto(
        Conversation conversation, Listing listing, User owner, User requester) => new()
    {
        Id = conversation.Id,
        ListingId = listing.Id,
        ListingTitle = listing.Title,
        ListingImageUrl = listing.Images.FirstOrDefault(i => i.IsCover)?.ImageUrl,
        OwnerId = owner.Id,
        OwnerName = owner.FullName,
        OwnerAvatarUrl = owner.AvatarUrl,
        RequesterId = requester.Id,
        RequesterName = requester.FullName,
        RequesterAvatarUrl = requester.AvatarUrl,
        LastMessageContent = null,
        LastMessageSenderId = null,
        LastMessageAt = conversation.LastMessageAt,
        CreatedAt = conversation.CreatedAt
    };
}
