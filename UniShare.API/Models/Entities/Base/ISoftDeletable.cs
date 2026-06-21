namespace UniShare.API.Models.Entities.Base;

public interface ISoftDeletable
{
    DateTime? DeletedAt { get; set; }
}
