using UniShare.API.Models.Entities.Base;

namespace UniShare.API.Models.Entities;

public class School : BaseEntity
{
    public string Name { get; set; } = null!;
    public string ShortName { get; set; } = null!;
    public string City { get; set; } = null!;
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<User> Users { get; set; } = new List<User>();
    public ICollection<Listing> Listings { get; set; } = new List<Listing>();
}
