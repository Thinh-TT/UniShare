using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class ListingImageConfiguration : IEntityTypeConfiguration<ListingImage>
{
    public void Configure(EntityTypeBuilder<ListingImage> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.ImageUrl).IsRequired().HasMaxLength(500);
        builder.Property(e => e.DisplayOrder).IsRequired();
        builder.Property(e => e.IsCover).IsRequired();
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");

        // Relationship
        builder.HasOne(e => e.Listing)
            .WithMany(l => l.Images)
            .HasForeignKey(e => e.ListingId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
