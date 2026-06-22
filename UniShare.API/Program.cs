using FluentValidation;
using FluentValidation.AspNetCore;
using UniShare.API.Extensions;
using UniShare.API.Filters;
using UniShare.API.Hubs;
using UniShare.API.Middleware;
using UniShare.API.Services;

var builder = WebApplication.CreateBuilder(args);

// Database
builder.Services.AddDatabase(builder.Configuration);

// Application services
builder.Services.AddApplicationServices();

// Controllers + FluentValidation + Response Wrapper
builder.Services.AddControllers(options =>
{
    options.Filters.Add<ResponseWrapperFilter>();
})
.ConfigureValidationErrors();

builder.Services.AddFluentValidationAutoValidation()
    .AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerWithGroups();

// JWT Authentication
builder.Services.AddJwtAuthentication(builder.Configuration);

// CORS
builder.Services.AddCorsPolicy(builder.Configuration);

var app = builder.Build();

// Global exception handling
app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Docker"))
{
    app.UseSwaggerWithUI();
}

// HTTPS redirection only outside Docker — the container listens on HTTP,
// and ngrok terminates TLS externally.
if (!app.Environment.IsEnvironment("Docker"))
{
    app.UseHttpsRedirection();
}
app.UseStaticFiles();
app.UseCors("UniShareMobile");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<NotificationHub>("/hubs/notifications");

// Seed admin user in development and Docker environments
if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Docker"))
{
    using var scope = app.Services.CreateScope();
    var seeder = scope.ServiceProvider.GetRequiredService<AdminSeedService>();
    await seeder.SeedAdminIfNotExistsAsync("admin@unishare.edu.vn", "Admin@123456!");
}

app.Run();

// Expose Program for WebApplicationFactory<T> in integration tests
public partial class Program { }
