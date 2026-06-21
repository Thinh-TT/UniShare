using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class ConversationConfiguration : IEntityTypeConfiguration<Conversation>
{
    public void Configure(EntityTypeBuilder<Conversation> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.LastMessageAt).HasColumnType("datetime2");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.OwnerId);
        builder.HasIndex(e => e.RequesterId);
        builder.HasIndex(e => e.ListingId);

        // Relationships
        builder.HasOne(e => e.Listing)
            .WithMany(l => l.Conversations)
            .HasForeignKey(e => e.ListingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.RentalRequest)
            .WithMany(r => r.Conversations)
            .HasForeignKey(e => e.RentalRequestId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Owner)
            .WithMany(u => u.ConversationsAsOwner)
            .HasForeignKey(e => e.OwnerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Requester)
            .WithMany(u => u.ConversationsAsRequester)
            .HasForeignKey(e => e.RequesterId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
