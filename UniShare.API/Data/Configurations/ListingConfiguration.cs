using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class ListingConfiguration : IEntityTypeConfiguration<Listing>
{
    public void Configure(EntityTypeBuilder<Listing> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Title).IsRequired().HasMaxLength(200);
        builder.Property(e => e.Description).IsRequired().HasMaxLength(2000);
        builder.Property(e => e.ListingType).IsRequired().HasConversion<string>().HasMaxLength(20);
        builder.Property(e => e.Status).IsRequired().HasConversion<string>().HasMaxLength(30);
        builder.Property(e => e.PricePerDay).IsRequired().HasColumnType("decimal(18,2)");
        builder.Property(e => e.DepositAmount).HasColumnType("decimal(18,2)");
        builder.Property(e => e.ConditionNote).HasMaxLength(500);

        builder.Property(e => e.ViewCount).IsRequired().HasDefaultValue(0);
        builder.Property(e => e.UpvoteCount).IsRequired().HasDefaultValue(0);
        builder.Property(e => e.CommentCount).IsRequired().HasDefaultValue(0);

        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");
        builder.Property(e => e.DeletedAt).HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.OwnerId);
        builder.HasIndex(e => e.CategoryId);
        builder.HasIndex(e => e.Status);
        builder.HasIndex(e => e.CreatedAt).IsDescending();

        // Relationships
        builder.HasOne(e => e.Owner)
            .WithMany(u => u.Listings)
            .HasForeignKey(e => e.OwnerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Category)
            .WithMany(c => c.Listings)
            .HasForeignKey(e => e.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.School)
            .WithMany(s => s.Listings)
            .HasForeignKey(e => e.SchoolId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Area)
            .WithMany(a => a.Listings)
            .HasForeignKey(e => e.AreaId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
