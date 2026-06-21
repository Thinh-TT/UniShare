using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Listings;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[ApiExplorerSettings(GroupName = "Listings")]
public class ListingsController : ControllerBase
{
    private readonly IListingService _listingService;
    private readonly IListingImageService _imageService;

    public ListingsController(IListingService listingService, IListingImageService imageService)
    {
        _listingService = listingService;
        _imageService = imageService;
    }

    /// <summary>Search and browse public listings with pagination, filters, and sorting</summary>
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(typeof(PagedResponse<ListingSummaryDto>), 200)]
    public async Task<IActionResult> GetListings([FromQuery] ListingFilterParams filters)
    {
        var result = await _listingService.SearchListingsAsync(filters);
        return Ok(result);
    }

    /// <summary>Get listing detail (increments view count)</summary>
    [HttpGet("{listingId:guid}")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<ListingDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> GetListing(Guid listingId)
    {
        var result = await _listingService.GetListingDetailAsync(listingId);
        return Ok(result);
    }

    /// <summary>Create a new listing</summary>
    [HttpPost]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<ListingDetailDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateListing([FromBody] CreateListingRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _listingService.CreateListingAsync(userId, request);
        return StatusCode(201, result);
    }

    /// <summary>Update own listing</summary>
    [HttpPut("{listingId:guid}")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<ListingDetailDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UpdateListing(Guid listingId, [FromBody] UpdateListingRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _listingService.UpdateListingAsync(listingId, userId, request);
        return Ok(result);
    }

    /// <summary>Close own listing</summary>
    [HttpPatch("{listingId:guid}/close")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CloseListing(Guid listingId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _listingService.CloseListingAsync(listingId, userId);
        return NoContent();
    }

    /// <summary>Soft-delete own listing</summary>
    [HttpDelete("{listingId:guid}")]
    [Authorize]
    [ProducesResponseType(204)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> DeleteListing(Guid listingId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _listingService.SoftDeleteListingAsync(listingId, userId);
        return NoContent();
    }

    /// <summary>Get current user's own listings</summary>
    [HttpGet("/api/v1/me/listings")]
    [Authorize]
    [ProducesResponseType(typeof(PagedResponse<ListingSummaryDto>), 200)]
    public async Task<IActionResult> GetMyListings(
        [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _listingService.GetMyListingsAsync(userId, page, pageSize);
        return Ok(result);
    }

    // --- Image endpoints ---

    /// <summary>Upload images to a listing (multipart/form-data)</summary>
    [HttpPost("{listingId:guid}/images")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<ListingImageDto>>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UploadImages(
        Guid listingId, [FromForm] List<IFormFile> files)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _imageService.UploadImagesAsync(listingId, userId, files);
        return StatusCode(201, result);
    }

    /// <summary>Set an image as the cover for a listing</summary>
    [HttpPatch("{listingId:guid}/images/{imageId:guid}/cover")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<ListingImageDto>>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> SetCoverImage(Guid listingId, Guid imageId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _imageService.SetCoverImageAsync(listingId, imageId, userId);
        return Ok(result);
    }

    /// <summary>Reorder images for a listing</summary>
    [HttpPut("{listingId:guid}/images/order")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<ListingImageDto>>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> ReorderImages(
        Guid listingId, [FromBody] ReorderImagesRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _imageService.ReorderImagesAsync(listingId, userId, request.ImageIds);
        return Ok(result);
    }

    /// <summary>Delete an image from a listing</summary>
    [HttpDelete("{listingId:guid}/images/{imageId:guid}")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<ListingImageDto>>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> DeleteImage(Guid listingId, Guid imageId)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _imageService.DeleteImageAsync(listingId, imageId, userId);
        return Ok(result);
    }
}
