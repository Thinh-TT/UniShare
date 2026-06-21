namespace UniShare.API.Models.DTOs.Listings;

public class ListingFilterParams
{
    public string? Keyword { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid? TagId { get; set; }
    public Guid? SchoolId { get; set; }
    public Guid? AreaId { get; set; }
    public string? ListingType { get; set; } // "Rent" or "Borrow"
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public string? SortBy { get; set; } // "Newest", "PriceAsc", "PriceDesc", "MostUpvotes"
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
