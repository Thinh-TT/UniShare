using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Metadata;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/admin")]
[ApiExplorerSettings(GroupName = "Admin")]
[Authorize(Policy = "RequireAdmin")]
public class AdminController : ControllerBase
{
    private readonly IAdminService _adminService;

    public AdminController(IAdminService adminService)
    {
        _adminService = adminService;
    }

    // ==================== Schools ====================

    /// <summary>Create a new school</summary>
    [HttpPost("schools")]
    [ProducesResponseType(typeof(ApiResponse<SchoolDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateSchool([FromBody] CreateSchoolRequest request)
    {
        var result = await _adminService.CreateSchoolAsync(request);
        return StatusCode(201, result);
    }

    /// <summary>Update an existing school</summary>
    [HttpPut("schools/{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<SchoolDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UpdateSchool(Guid id, [FromBody] UpdateSchoolRequest request)
    {
        var result = await _adminService.UpdateSchoolAsync(id, request);
        return Ok(result);
    }

    /// <summary>Deactivate a school (soft-disable)</summary>
    [HttpPatch("schools/{id:guid}/deactivate")]
    [ProducesResponseType(typeof(ApiResponse<SchoolDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> DeactivateSchool(Guid id)
    {
        var result = await _adminService.DeactivateSchoolAsync(id);
        return Ok(result);
    }

    // ==================== Areas ====================

    /// <summary>Create a new area</summary>
    [HttpPost("areas")]
    [ProducesResponseType(typeof(ApiResponse<AreaDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateArea([FromBody] CreateAreaRequest request)
    {
        var result = await _adminService.CreateAreaAsync(request);
        return StatusCode(201, result);
    }

    /// <summary>Update an existing area</summary>
    [HttpPut("areas/{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<AreaDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UpdateArea(Guid id, [FromBody] UpdateAreaRequest request)
    {
        var result = await _adminService.UpdateAreaAsync(id, request);
        return Ok(result);
    }

    /// <summary>Deactivate an area (soft-disable)</summary>
    [HttpPatch("areas/{id:guid}/deactivate")]
    [ProducesResponseType(typeof(ApiResponse<AreaDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> DeactivateArea(Guid id)
    {
        var result = await _adminService.DeactivateAreaAsync(id);
        return Ok(result);
    }

    // ==================== Categories ====================

    /// <summary>Create a new category</summary>
    [HttpPost("categories")]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryRequest request)
    {
        var result = await _adminService.CreateCategoryAsync(request);
        return StatusCode(201, result);
    }

    /// <summary>Update an existing category</summary>
    [HttpPut("categories/{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> UpdateCategory(Guid id, [FromBody] UpdateCategoryRequest request)
    {
        var result = await _adminService.UpdateCategoryAsync(id, request);
        return Ok(result);
    }

    /// <summary>Deactivate a category (soft-disable)</summary>
    [HttpPatch("categories/{id:guid}/deactivate")]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 404)]
    public async Task<IActionResult> DeactivateCategory(Guid id)
    {
        var result = await _adminService.DeactivateCategoryAsync(id);
        return Ok(result);
    }
}
