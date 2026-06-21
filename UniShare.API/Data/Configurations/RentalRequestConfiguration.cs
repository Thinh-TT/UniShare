using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class RentalRequestConfiguration : IEntityTypeConfiguration<RentalRequest>
{
    public void Configure(EntityTypeBuilder<RentalRequest> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Status).IsRequired().HasConversion<string>().HasMaxLength(30);
        builder.Property(e => e.StartDate).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.EndDate).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.Message).HasMaxLength(500);
        builder.Property(e => e.TotalPrice).IsRequired().HasColumnType("decimal(18,2)");
        builder.Property(e => e.DepositAmount).HasColumnType("decimal(18,2)");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        // Indexes
        builder.HasIndex(e => e.ListingId);
        builder.HasIndex(e => e.RequesterId);
        builder.HasIndex(e => e.OwnerId);
        builder.HasIndex(e => e.Status);

        // Relationships
        builder.HasOne(e => e.Listing)
            .WithMany(l => l.RentalRequests)
            .HasForeignKey(e => e.ListingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Requester)
            .WithMany(u => u.RentalRequestsAsRequester)
            .HasForeignKey(e => e.RequesterId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Owner)
            .WithMany(u => u.RentalRequestsAsOwner)
            .HasForeignKey(e => e.OwnerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
