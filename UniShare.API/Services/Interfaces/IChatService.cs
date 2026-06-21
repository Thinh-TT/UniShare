using UniShare.API.Models;
using UniShare.API.Models.DTOs.Chat;

namespace UniShare.API.Services.Interfaces;

public interface IChatService
{
    Task<(ConversationDetailDto Conversation, bool IsNew)> CreateOrOpenConversationAsync(
        Guid listingId, Guid userId, CreateConversationRequest? request);

    Task<PagedResponse<ConversationSummaryDto>> GetMyConversationsAsync(
        Guid userId, int page, int pageSize);

    Task<ConversationDetailDto> GetConversationDetailAsync(Guid conversationId, Guid userId);

    Task<PagedResponse<MessageDto>> GetMessagesAsync(
        Guid conversationId, Guid userId, int page, int pageSize);

    Task<MessageDto> SendMessageAsync(Guid conversationId, Guid userId, string content);

    Task<int> MarkMessagesAsReadAsync(Guid conversationId, Guid userId);

    Task<ConversationSummaryDto> GetConversationSummaryAsync(Guid conversationId, Guid userId);
}
