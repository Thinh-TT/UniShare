using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class MessageConfiguration : IEntityTypeConfiguration<Message>
{
    public void Configure(EntityTypeBuilder<Message> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Content).IsRequired().HasMaxLength(2000);
        builder.Property(e => e.Status).IsRequired().HasConversion<string>().HasMaxLength(20);
        builder.Property(e => e.ReadAt).HasColumnType("datetime2");
        builder.Property(e => e.DeletedAt).HasColumnType("datetime2");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.ConversationId);
        builder.HasIndex(e => e.CreatedAt);

        // Relationships
        builder.HasOne(e => e.Conversation)
            .WithMany(c => c.Messages)
            .HasForeignKey(e => e.ConversationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.Sender)
            .WithMany(u => u.Messages)
            .HasForeignKey(e => e.SenderId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
