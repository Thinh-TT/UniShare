using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Rating).IsRequired();
        builder.Property(e => e.Comment).HasMaxLength(1000);
        builder.Property(e => e.ReputationDelta).IsRequired().HasColumnType("decimal(5,2)");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.RentalRequestId);
        builder.HasIndex(e => e.RevieweeId);

        // Relationships
        builder.HasOne(e => e.RentalRequest)
            .WithMany(r => r.Reviews)
            .HasForeignKey(e => e.RentalRequestId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Reviewer)
            .WithMany(u => u.ReviewsAsReviewer)
            .HasForeignKey(e => e.ReviewerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Reviewee)
            .WithMany(u => u.ReviewsAsReviewee)
            .HasForeignKey(e => e.RevieweeId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
