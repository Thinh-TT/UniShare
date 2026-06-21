using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data.Configurations;

public class DepositConfiguration : IEntityTypeConfiguration<Deposit>
{
    public void Configure(EntityTypeBuilder<Deposit> builder)
    {
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Id).ValueGeneratedNever();

        builder.Property(e => e.Amount).IsRequired().HasColumnType("decimal(18,2)");
        builder.Property(e => e.Status).IsRequired().HasConversion<string>().HasMaxLength(30);
        builder.Property(e => e.PaymentProvider).HasMaxLength(50);
        builder.Property(e => e.ProviderTransactionId).HasMaxLength(150);
        builder.Property(e => e.PaidAt).HasColumnType("datetime2");
        builder.Property(e => e.RefundedAt).HasColumnType("datetime2");
        builder.Property(e => e.CreatedAt).IsRequired().HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        // Unique one-to-one relationship
        builder.HasIndex(e => e.RentalRequestId).IsUnique();

        // Relationship
        builder.HasOne(e => e.RentalRequest)
            .WithOne(r => r.Deposit)
            .HasForeignKey<Deposit>(e => e.RentalRequestId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
