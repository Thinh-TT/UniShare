using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Metadata;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[ApiExplorerSettings(GroupName = "Auth")]
public class MetadataController : ControllerBase
{
    private readonly IMetadataService _metadataService;

    public MetadataController(IMetadataService metadataService)
    {
        _metadataService = metadataService;
    }

    /// <summary>Get all active schools</summary>
    [HttpGet("api/v1/schools")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<List<SchoolDto>>), 200)]
    public async Task<IActionResult> GetSchools()
    {
        var result = await _metadataService.GetActiveSchoolsAsync();
        return Ok(result);
    }

    /// <summary>Get all active areas</summary>
    [HttpGet("api/v1/areas")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<List<AreaDto>>), 200)]
    public async Task<IActionResult> GetAreas()
    {
        var result = await _metadataService.GetActiveAreasAsync();
        return Ok(result);
    }

    /// <summary>Get all active categories</summary>
    [HttpGet("api/v1/categories")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<List<CategoryDto>>), 200)]
    public async Task<IActionResult> GetCategories()
    {
        var result = await _metadataService.GetActiveCategoriesAsync();
        return Ok(result);
    }

    /// <summary>Search tags with optional keyword and pagination</summary>
    [HttpGet("api/v1/tags")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(PagedResponse<TagDto>), 200)]
    public async Task<IActionResult> GetTags(
        [FromQuery] string? keyword = null,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var (items, totalCount) = await _metadataService.GetTagsAsync(keyword, page, pageSize);

        return Ok(new PagedResponse<TagDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            TotalItems = totalCount
        });
    }
}
