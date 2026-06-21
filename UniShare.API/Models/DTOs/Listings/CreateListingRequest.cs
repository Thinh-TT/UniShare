namespace UniShare.API.Models.DTOs.Listings;

public class CreateListingRequest
{
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public Guid CategoryId { get; set; }
    public string ListingType { get; set; } = null!; // "Rent" or "Borrow"
    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }
    public decimal PricePerDay { get; set; }
    public decimal? DepositAmount { get; set; }
    public string? ConditionNote { get; set; }
    public List<string> TagNames { get; set; } = new();
}
