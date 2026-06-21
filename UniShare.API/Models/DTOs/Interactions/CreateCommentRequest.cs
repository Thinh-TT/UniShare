namespace UniShare.API.Models.DTOs.Interactions;

public class CreateCommentRequest
{
    public string Content { get; set; } = null!;
    public Guid? ParentCommentId { get; set; }
}
