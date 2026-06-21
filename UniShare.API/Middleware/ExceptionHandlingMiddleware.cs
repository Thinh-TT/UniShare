using System.Net;
using System.Text.Json;
using UniShare.API.Exceptions;

namespace UniShare.API.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (DomainException ex)
        {
            _logger.LogWarning(ex, "Domain exception processing {Method} {Path}: {Message}",
                context.Request.Method, context.Request.Path, ex.Message);

            context.Response.ContentType = "application/problem+json";
            context.Response.StatusCode = ex.StatusCode;

            var type = ex.StatusCode switch
            {
                400 => "https://unishare/errors/validation",
                401 => "https://unishare/errors/unauthorized",
                403 => "https://unishare/errors/forbidden",
                404 => "https://unishare/errors/not-found",
                409 => "https://unishare/errors/conflict",
                _ => "https://unishare/errors/domain-error"
            };

            var title = ex.StatusCode switch
            {
                400 => "Validation Error",
                401 => "Unauthorized",
                403 => "Forbidden",
                404 => "Not Found",
                409 => "Conflict",
                _ => "Domain Error"
            };

            var problem = new
            {
                type,
                title,
                status = ex.StatusCode,
                detail = ex.Message,
                instance = context.Request.Path.ToString()
            };

            var json = JsonSerializer.Serialize(problem, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });

            await context.Response.WriteAsync(json);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception processing {Method} {Path}",
                context.Request.Method, context.Request.Path);

            context.Response.ContentType = "application/problem+json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            var problem = new
            {
                type = "https://unishare/errors/internal-server-error",
                title = "An error occurred",
                status = 500,
                detail = "An unexpected error occurred. Please try again later.",
                instance = context.Request.Path.ToString()
            };

            var json = JsonSerializer.Serialize(problem, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });

            await context.Response.WriteAsync(json);
        }
    }
}
