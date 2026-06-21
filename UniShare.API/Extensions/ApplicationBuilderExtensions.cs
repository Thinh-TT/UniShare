namespace UniShare.API.Extensions;

public static class ApplicationBuilderExtensions
{
    public static IApplicationBuilder UseSwaggerWithUI(this IApplicationBuilder app)
    {
        app.UseSwagger();
        app.UseSwaggerUI(options =>
        {
            var modules = new[]
            {
                "Auth", "Users", "Listings", "Interactions", "Chat",
                "RentalRequests", "Reviews", "Notifications", "Admin"
            };

            foreach (var module in modules)
            {
                options.SwaggerEndpoint(
                    $"/swagger/{module}/swagger.json",
                    $"UniShare {module}");
            }

            options.DefaultModelsExpandDepth(-1);
        });

        return app;
    }
}
