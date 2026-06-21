using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UniShare.API.Models;
using UniShare.API.Models.DTOs.Auth;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[ApiExplorerSettings(GroupName = "Auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>Register a new user account</summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<RegisterResponse>), 201)]
    [ProducesResponseType(typeof(ProblemDetails), 400)]
    [ProducesResponseType(typeof(ProblemDetails), 409)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var result = await _authService.RegisterAsync(request);
        return StatusCode(201, result);
    }

    /// <summary>Login with email or phone number</summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    [ProducesResponseType(typeof(ProblemDetails), 403)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var result = await _authService.LoginAsync(request);
        return Ok(result);
    }

    /// <summary>Get a new access token using a refresh token</summary>
    [HttpPost("refresh-token")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<RefreshTokenResponse>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 401)]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        var result = await _authService.RefreshTokenAsync(request.RefreshToken);
        return Ok(result);
    }

    /// <summary>Logout and invalidate the refresh token</summary>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(204)]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenRequest request)
    {
        var userId = Guid.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _authService.LogoutAsync(userId, request.RefreshToken);
        return NoContent();
    }
}
