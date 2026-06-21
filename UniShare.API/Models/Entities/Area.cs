using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class Area : BaseEntity
{
    public string Name { get; set; } = null!;
    public string City { get; set; } = null!;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<User> Users { get; set; } = new List<User>();
    public ICollection<Listing> Listings { get; set; } = new List<Listing>();
}
