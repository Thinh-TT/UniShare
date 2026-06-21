namespace UniShare.API.Models.DTOs.Listings;

public class UpdateListingRequest
{
    public string? Title { get; set; }
    public string? Description { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }
    public decimal? PricePerDay { get; set; }
    public decimal? DepositAmount { get; set; }
    public string? ConditionNote { get; set; }
    public List<string>? TagNames { get; set; }
}
