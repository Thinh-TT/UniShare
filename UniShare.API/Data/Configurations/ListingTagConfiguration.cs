using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class ListingTagConfiguration : IEntityTypeConfiguration<ListingTag>
{
    public void Configure(EntityTypeBuilder<ListingTag> builder)
    {
        // Composite primary key
        builder.HasKey(e => new { e.ListingId, e.TagId });

        // Relationships
        builder.HasOne(e => e.Listing)
            .WithMany(l => l.ListingTags)
            .HasForeignKey(e => e.ListingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.Tag)
            .WithMany(t => t.ListingTags)
            .HasForeignKey(e => e.TagId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
