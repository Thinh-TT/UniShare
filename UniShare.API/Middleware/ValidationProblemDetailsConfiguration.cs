using Microsoft.AspNetCore.Mvc;

namespace UniShare.API.Middleware;

public static class ValidationProblemDetailsConfiguration
{
    public static IMvcBuilder ConfigureValidationErrors(this IMvcBuilder builder)
    {
        builder.ConfigureApiBehaviorOptions(options =>
        {
            options.InvalidModelStateResponseFactory = context =>
            {
                var errors = context.ModelState
                    .Where(e => e.Value?.Errors.Count > 0)
                    .ToDictionary(
                        e => e.Key,
                        e => e.Value!.Errors.Select(x =>
                            string.IsNullOrEmpty(x.ErrorMessage)
                                ? "Invalid value"
                                : x.ErrorMessage).ToArray()
                    );

                var problem = new ValidationProblemDetails(context.ModelState)
                {
                    Type = "https://unishare/errors/validation",
                    Title = "Validation failed",
                    Status = StatusCodes.Status400BadRequest,
                    Detail = "One or more validation errors occurred.",
                    Instance = context.HttpContext.Request.Path
                };

                return new BadRequestObjectResult(problem)
                {
                    ContentTypes = { "application/problem+json" }
                };
            };

            options.SuppressModelStateInvalidFilter = false;
        });

        return builder;
    }
}
