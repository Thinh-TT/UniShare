namespace UniShare.API.Models.DTOs.RentalRequests;

public class CreateRentalRequest
{
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string? Message { get; set; }
}
