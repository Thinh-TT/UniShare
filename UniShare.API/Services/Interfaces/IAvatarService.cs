namespace UniShare.API.Services.Interfaces;

/// <summary>
/// Service for handling user avatar upload and management.
/// </summary>
public interface IAvatarService
{
    /// <summary>
    /// Uploads a new avatar for the specified user.
    /// Validates file type (.jpg/.jpeg/.png/.webp) and size (≤5 MB).
    /// Deletes the old avatar file if one exists.
    /// </summary>
    /// <param name="userId">The user's ID.</param>
    /// <param name="file">The uploaded image file.</param>
    /// <returns>The new avatar URL (server-relative path).</returns>
    Task<string> UploadAvatarAsync(Guid userId, IFormFile file);
}
