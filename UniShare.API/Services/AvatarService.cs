using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

/// <summary>
/// Handles avatar file upload, validation, and cleanup.
/// </summary>
public class AvatarService : IAvatarService
{
    private readonly AppDbContext _context;
    private readonly IWebHostEnvironment _env;

    private static readonly HashSet<string> AllowedExtensions = new(
        StringComparer.OrdinalIgnoreCase) { ".jpg", ".jpeg", ".png", ".webp" };

    private const long MaxFileSize = 5 * 1024 * 1024; // 5 MB
    private const string UploadSubfolder = "uploads/avatars";

    public AvatarService(AppDbContext context, IWebHostEnvironment env)
    {
        _context = context;
        _env = env;
    }

    public async Task<string> UploadAvatarAsync(Guid userId, IFormFile file)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (user is null)
            throw new NotFoundException("User not found");

        // Validate file extension
        var ext = Path.GetExtension(file.FileName);
        if (!AllowedExtensions.Contains(ext))
            throw new BusinessRuleViolationException(
                $"File type '{ext}' is not allowed. Allowed: {string.Join(", ", AllowedExtensions)}");

        // Validate file size
        if (file.Length > MaxFileSize)
            throw new BusinessRuleViolationException(
                $"File exceeds the maximum size of 5 MB");

        if (file.Length == 0)
            throw new BusinessRuleViolationException("File is empty");

        // Ensure upload directory exists
        var uploadDir = GetUploadDirectory();
        Directory.CreateDirectory(uploadDir);

        // Delete old avatar file if it's a local file (not external URL)
        if (!string.IsNullOrEmpty(user.AvatarUrl))
        {
            DeleteOldAvatarFile(user.AvatarUrl);
        }

        // Save new file
        var fileName = $"{Guid.NewGuid()}{ext}";
        var filePath = Path.Combine(uploadDir, fileName);

        await using var stream = new FileStream(filePath, FileMode.Create);
        await file.CopyToAsync(stream);

        // Update user entity
        var avatarUrl = $"/{UploadSubfolder}/{fileName}";
        user.AvatarUrl = avatarUrl;
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return avatarUrl;
    }

    /// <summary>
    /// Deletes an old avatar file from disk.
    /// Only deletes files that are under /uploads/avatars/ (local uploads),
    /// not external URLs (e.g. Gravatar, Google avatar).
    /// </summary>
    private void DeleteOldAvatarFile(string avatarUrl)
    {
        // Only delete files that start with our uploads path
        if (!avatarUrl.StartsWith($"/{UploadSubfolder}/", StringComparison.OrdinalIgnoreCase))
            return;

        var relativePath = avatarUrl.TrimStart('/');
        var filePath = Path.Combine(
            _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot"),
            relativePath);

        if (File.Exists(filePath))
        {
            File.Delete(filePath);
        }
    }

    private string GetUploadDirectory()
    {
        return Path.Combine(
            _env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot"),
            UploadSubfolder);
    }
}
