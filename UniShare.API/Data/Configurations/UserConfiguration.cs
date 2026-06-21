using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Email).IsRequired().HasMaxLength(256);
        builder.Property(e => e.PhoneNumber).HasMaxLength(20);
        builder.Property(e => e.PasswordHash).IsRequired();
        builder.Property(e => e.FullName).IsRequired().HasMaxLength(150);
        builder.Property(e => e.AvatarUrl).HasMaxLength(500);

        builder.Property(e => e.ReputationScore).IsRequired().HasColumnType("decimal(5,2)").HasDefaultValue(100.00m);
        builder.Property(e => e.TotalReviews).IsRequired().HasDefaultValue(0);
        builder.Property(e => e.IsVerified).IsRequired().HasDefaultValue(false);
        builder.Property(e => e.IsActive).IsRequired().HasDefaultValue(true);

        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        // Unique constraints
        builder.HasIndex(e => e.Email).IsUnique();
        builder.HasIndex(e => e.PhoneNumber).IsUnique();

        // Relationships
        builder.HasOne(e => e.School)
            .WithMany(s => s.Users)
            .HasForeignKey(e => e.SchoolId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Area)
            .WithMany(a => a.Users)
            .HasForeignKey(e => e.AreaId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
