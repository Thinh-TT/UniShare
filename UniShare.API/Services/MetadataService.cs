using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Models.DTOs.Metadata;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class MetadataService : IMetadataService
{
    private readonly AppDbContext _context;

    public MetadataService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<SchoolDto>> GetActiveSchoolsAsync()
    {
        return await _context.Schools
            .Where(s => s.IsActive)
            .OrderBy(s => s.Name)
            .Select(s => new SchoolDto
            {
                Id = s.Id,
                Name = s.Name,
                ShortName = s.ShortName,
                City = s.City
            })
            .ToListAsync();
    }

    public async Task<List<AreaDto>> GetActiveAreasAsync()
    {
        return await _context.Areas
            .Where(a => a.IsActive)
            .OrderBy(a => a.Name)
            .Select(a => new AreaDto
            {
                Id = a.Id,
                Name = a.Name,
                City = a.City,
                Description = a.Description
            })
            .ToListAsync();
    }

    public async Task<List<CategoryDto>> GetActiveCategoriesAsync()
    {
        return await _context.Categories
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Slug = c.Slug,
                Description = c.Description
            })
            .ToListAsync();
    }

    public async Task<(List<TagDto> Items, int TotalCount)> GetTagsAsync(
        string? keyword = null, int page = 1, int pageSize = 20)
    {
        var query = _context.Tags.AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var lowerKeyword = keyword.Trim().ToLower();
            query = query.Where(t => t.Name.ToLower().Contains(lowerKeyword)
                                  || t.Slug.ToLower().Contains(lowerKeyword));
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderBy(t => t.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(t => new TagDto
            {
                Id = t.Id,
                Name = t.Name,
                Slug = t.Slug
            })
            .ToListAsync();

        return (items, totalCount);
    }
}
