using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Type).IsRequired().HasConversion<string>().HasMaxLength(30);
        builder.Property(e => e.Title).IsRequired().HasMaxLength(200);
        builder.Property(e => e.Body).IsRequired().HasMaxLength(500);
        builder.Property(e => e.ReferenceType).HasMaxLength(50);
        builder.Property(e => e.IsRead).IsRequired().HasDefaultValue(false);
        builder.Property(e => e.ReadAt).HasColumnType("datetime2");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.UserId);
        builder.HasIndex(e => e.IsRead);

        // Relationship
        builder.HasOne(e => e.User)
            .WithMany(u => u.Notifications)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
