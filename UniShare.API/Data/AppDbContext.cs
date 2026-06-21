using System.Reflection;
using Microsoft.EntityFrameworkCore;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    // Reference data
    public DbSet<School> Schools => Set<School>();
    public DbSet<Area> Areas => Set<Area>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Tag> Tags => Set<Tag>();

    // Core entities
    public DbSet<User> Users => Set<User>();
    public DbSet<Listing> Listings => Set<Listing>();
    public DbSet<ListingImage> ListingImages => Set<ListingImage>();
    public DbSet<ListingTag> ListingTags => Set<ListingTag>();

    // Interactions
    public DbSet<Upvote> Upvotes => Set<Upvote>();
    public DbSet<Comment> Comments => Set<Comment>();

    // Rental & Payment
    public DbSet<RentalRequest> RentalRequests => Set<RentalRequest>();
    public DbSet<Deposit> Deposits => Set<Deposit>();

    // Chat
    public DbSet<Conversation> Conversations => Set<Conversation>();
    public DbSet<Message> Messages => Set<Message>();

    // Reviews & Notifications
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Notification> Notifications => Set<Notification>();

    // Auth
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all IEntityTypeConfiguration<T> classes from this assembly
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        // Global query filters for soft-delete entities
        modelBuilder.Entity<Listing>().HasQueryFilter(l => l.DeletedAt == null);
        modelBuilder.Entity<Comment>().HasQueryFilter(c => c.DeletedAt == null);
        modelBuilder.Entity<Message>().HasQueryFilter(m => m.DeletedAt == null);

        // Seed baseline data
        SeedData.Seed(modelBuilder);
    }
}
