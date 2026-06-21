using FluentValidation;
using FluentValidation.AspNetCore;
using UniShare.API.Extensions;
using UniShare.API.Filters;
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

if (app.Environment.IsDevelopment())
{
    app.UseSwaggerWithUI();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseCors("UniShareMobile");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Seed admin user in development
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var seeder = scope.ServiceProvider.GetRequiredService<AdminSeedService>();
    await seeder.SeedAdminIfNotExistsAsync("admin@unishare.edu.vn", "Admin@123456!");
}

app.Run();
