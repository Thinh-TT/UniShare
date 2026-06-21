using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Token).IsRequired().HasMaxLength(512);
        builder.Property(e => e.ExpiresAt).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.IsRevoked).IsRequired().HasDefaultValue(false);
        builder.Property(e => e.RevokedAt).HasColumnType("datetime2");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Fast lookup by token during refresh/logout
        builder.HasIndex(e => e.Token).IsUnique();

        // Fast lookup for all active tokens of a user
        builder.HasIndex(e => new { e.UserId, e.IsRevoked });

        // Relationship
        builder.HasOne(e => e.User)
            .WithMany()
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
