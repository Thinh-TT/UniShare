namespace UniShare.API.Models.DTOs.Notifications;

public class NotificationFilterParams
{
    public bool? IsRead { get; set; }
    public string? Type { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
