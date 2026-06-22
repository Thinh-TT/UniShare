using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using UniShare.API.Data;
using UniShare.API.Models;
using UniShare.API.Services;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(connectionString));

        return services;
    }

    public static IServiceCollection AddSwaggerWithGroups(this IServiceCollection services)
    {
        services.AddSwaggerGen(options =>
        {
            var modules = new (string Name, string Title)[]
            {
                ("Auth", "Authentication & Authorization"),
                ("Users", "User profiles"),
                ("Listings", "Item listings CRUD, search, images"),
                ("Interactions", "Upvotes, comments"),
                ("Chat", "Conversations, messages, SignalR"),
                ("RentalRequests", "Rental/borrow requests, deposits"),
                ("Reviews", "User reviews"),
                ("Notifications", "User notifications"),
                ("Admin", "Admin metadata management")
            };

            foreach (var (name, title) in modules)
            {
                options.SwaggerDoc(name, new()
                {
                    Title = $"UniShare API - {title}",
                    Version = "v1",
                    Description = $"Endpoints for {name}"
                });
            }

            // Include XML comments if generated
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            if (File.Exists(xmlPath))
                options.IncludeXmlComments(xmlPath);

            // JWT auth in Swagger UI
            options.AddSecurityDefinition("Bearer", new()
            {
                Name = "Authorization",
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = ParameterLocation.Header,
                Description = "Enter JWT token"
            });

            options.AddSecurityRequirement(new()
            {
                {
                    new()
                    {
                        Reference = new() { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
                    },
                    Array.Empty<string>()
                }
            });
        });

        return services;
    }

    public static IServiceCollection AddJwtAuthentication(
        this IServiceCollection services, IConfiguration configuration)
    {
        var jwtSection = configuration.GetSection(JwtSettings.SectionName);
        services.Configure<JwtSettings>(jwtSection);

        var jwtSettings = jwtSection.Get<JwtSettings>()
            ?? throw new InvalidOperationException("JWT settings not configured");

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(jwtSettings.SecretKey)),
                ValidateIssuer = true,
                ValidIssuer = jwtSettings.Issuer,
                ValidateAudience = true,
                ValidAudience = jwtSettings.Audience,
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            };

            // Allow SignalR to receive JWT via query string
            options.Events = new JwtBearerEvents
            {
                OnMessageReceived = context =>
                {
                    var accessToken = context.Request.Query["access_token"];
                    var path = context.HttpContext.Request.Path;
                    if (!string.IsNullOrEmpty(accessToken) &&
                        path.StartsWithSegments("/hubs"))
                    {
                        context.Token = accessToken;
                    }
                    return Task.CompletedTask;
                }
            };
        });

        services.AddAuthorization(options =>
        {
            options.AddPolicy("RequireAdmin", policy =>
                policy.RequireRole(UniShare.API.Models.Enums.Roles.Admin));
            options.AddPolicy("RequireAuthenticated", policy =>
                policy.RequireAuthenticatedUser());
        });

        // Register JWT service
        services.AddScoped<IJwtService, JwtService>();

        return services;
    }

    public static IServiceCollection AddCorsPolicy(
        this IServiceCollection services, IConfiguration configuration)
    {
        var allowedOrigins = configuration
            .GetSection("Cors:AllowedOrigins")
            .Get<string[]>()
            ?? new[] { "http://localhost:*", "http://10.0.2.2:*" };

        services.AddCors(options =>
        {
            options.AddPolicy("UniShareMobile", policy =>
            {
                policy.SetIsOriginAllowed(origin =>
                    {
                        foreach (var pattern in allowedOrigins)
                        {
                            if (MatchWildcardOrigin(pattern, origin))
                                return true;
                        }
                        return false;
                    })
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials();
            });
        });

        return services;
    }

    /// <summary>
    /// Matches an origin against a pattern that may contain a single <c>*</c>
    /// wildcard in the port or path position.
    /// </summary>
    /// <example>
    /// MatchWildcardOrigin("http://localhost:*", "http://localhost:5056") → true
    /// MatchWildcardOrigin("http://10.0.2.2:*", "http://10.0.2.2:5056") → true
    /// MatchWildcardOrigin("http://127.0.0.1:*", "http://127.0.0.1:8080") → true
    /// </example>
    private static bool MatchWildcardOrigin(string pattern, string origin)
    {
        if (pattern == origin)
            return true;

        // Escape regex special chars except *
        var regex = "^"
            + System.Text.RegularExpressions.Regex.Escape(pattern).Replace("\\*", "[^/]+")
            + "$";

        return System.Text.RegularExpressions.Regex.IsMatch(origin, regex);
    }

    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IMetadataService, MetadataService>();
        services.AddScoped<IListingService, ListingService>();
        services.AddScoped<IListingImageService, ListingImageService>();
        services.AddSignalR();
        services.AddScoped<IInteractionService, InteractionService>();
        services.AddScoped<IChatService, ChatService>();
        services.AddScoped<IAdminService, AdminService>();
        services.AddScoped<AdminSeedService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddScoped<IRentalService, RentalService>();
        services.AddScoped<IDepositService, DepositService>();
        services.AddScoped<IReviewService, ReviewService>();

        return services;
    }
}
