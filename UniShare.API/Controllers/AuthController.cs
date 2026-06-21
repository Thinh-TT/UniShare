using Microsoft.AspNetCore.Mvc;

namespace UniShare.API.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[ApiExplorerSettings(GroupName = "Auth")]
public class AuthController : ControllerBase
{
    /// <summary>
    /// Health check ping endpoint
    /// </summary>
    [HttpGet("ping")]
    public IActionResult Ping()
    {
        return Ok(new { status = "alive" });
    }
}
