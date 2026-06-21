using FluentValidation;
using FluentValidation.AspNetCore;
using UniShare.API.Extensions;
using UniShare.API.Filters;
using UniShare.API.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Database
builder.Services.AddDatabase(builder.Configuration);

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
app.UseCors("UniShareMobile");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
