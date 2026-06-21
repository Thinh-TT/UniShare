using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class AdminSeedService
{
    private readonly AppDbContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public AdminSeedService(AppDbContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public async Task SeedAdminIfNotExistsAsync(string email, string password)
    {
        if (await _context.Users.AnyAsync(u => u.Role == Roles.Admin))
            return;

        var admin = new User
        {
            Email = email,
            FullName = "System Administrator",
            PasswordHash = _passwordHasher.Hash(password),
            Role = Roles.Admin,
            IsActive = true,
            IsVerified = true,
            ReputationScore = 0
        };

        _context.Users.Add(admin);
        await _context.SaveChangesAsync();
    }
}
