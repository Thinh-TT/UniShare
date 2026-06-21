using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class UpvoteConfiguration : IEntityTypeConfiguration<Upvote>
{
    public void Configure(EntityTypeBuilder<Upvote> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Unique constraint: one upvote per user per listing
        builder.HasIndex(e => new { e.ListingId, e.UserId }).IsUnique();

        // Relationships
        builder.HasOne(e => e.Listing)
            .WithMany(l => l.Upvotes)
            .HasForeignKey(e => e.ListingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.User)
            .WithMany(u => u.Upvotes)
            .HasForeignKey(e => e.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
