using Microsoft.EntityFrameworkCore;
using UniShare.API.Data;
using UniShare.API.Exceptions;
using UniShare.API.Models.DTOs.Metadata;
using UniShare.API.Models.Entities;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Services;

public class AdminService : IAdminService
{
    private readonly AppDbContext _context;

    public AdminService(AppDbContext context)
    {
        _context = context;
    }

    // ==================== Schools ====================

    public async Task<SchoolDto> CreateSchoolAsync(CreateSchoolRequest request)
    {
        if (await _context.Schools.AnyAsync(s => s.Name == request.Name))
            throw new BusinessRuleViolationException($"School with name '{request.Name}' already exists.");

        var school = new School
        {
            Name = request.Name,
            ShortName = request.ShortName,
            City = request.City
        };

        _context.Schools.Add(school);
        await _context.SaveChangesAsync();

        return MapSchool(school);
    }

    public async Task<SchoolDto> UpdateSchoolAsync(Guid id, UpdateSchoolRequest request)
    {
        var school = await _context.Schools.FirstOrDefaultAsync(s => s.Id == id)
            ?? throw new NotFoundException("School not found.");

        if (await _context.Schools.AnyAsync(s => s.Name == request.Name && s.Id != id))
            throw new BusinessRuleViolationException($"School with name '{request.Name}' already exists.");

        school.Name = request.Name;
        school.ShortName = request.ShortName;
        school.City = request.City;
        await _context.SaveChangesAsync();

        return MapSchool(school);
    }

    public async Task<SchoolDto> DeactivateSchoolAsync(Guid id)
    {
        var school = await _context.Schools.FirstOrDefaultAsync(s => s.Id == id)
            ?? throw new NotFoundException("School not found.");

        if (!school.IsActive)
            return MapSchool(school);

        school.IsActive = false;
        await _context.SaveChangesAsync();

        return MapSchool(school);
    }

    // ==================== Areas ====================

    public async Task<AreaDto> CreateAreaAsync(CreateAreaRequest request)
    {
        if (await _context.Areas.AnyAsync(a => a.Name == request.Name && a.City == request.City))
            throw new BusinessRuleViolationException($"Area with name '{request.Name}' in '{request.City}' already exists.");

        var area = new Area
        {
            Name = request.Name,
            City = request.City,
            Description = request.Description
        };

        _context.Areas.Add(area);
        await _context.SaveChangesAsync();

        return MapArea(area);
    }

    public async Task<AreaDto> UpdateAreaAsync(Guid id, UpdateAreaRequest request)
    {
        var area = await _context.Areas.FirstOrDefaultAsync(a => a.Id == id)
            ?? throw new NotFoundException("Area not found.");

        if (await _context.Areas.AnyAsync(a => a.Name == request.Name && a.City == request.City && a.Id != id))
            throw new BusinessRuleViolationException($"Area with name '{request.Name}' in '{request.City}' already exists.");

        area.Name = request.Name;
        area.City = request.City;
        area.Description = request.Description;
        await _context.SaveChangesAsync();

        return MapArea(area);
    }

    public async Task<AreaDto> DeactivateAreaAsync(Guid id)
    {
        var area = await _context.Areas.FirstOrDefaultAsync(a => a.Id == id)
            ?? throw new NotFoundException("Area not found.");

        if (!area.IsActive)
            return MapArea(area);

        area.IsActive = false;
        await _context.SaveChangesAsync();

        return MapArea(area);
    }

    // ==================== Categories ====================

    public async Task<CategoryDto> CreateCategoryAsync(CreateCategoryRequest request)
    {
        if (await _context.Categories.AnyAsync(c => c.Name == request.Name))
            throw new BusinessRuleViolationException($"Category with name '{request.Name}' already exists.");

        if (await _context.Categories.AnyAsync(c => c.Slug == request.Slug))
            throw new BusinessRuleViolationException($"Category with slug '{request.Slug}' already exists.");

        var category = new Category
        {
            Name = request.Name,
            Slug = request.Slug,
            Description = request.Description
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        return MapCategory(category);
    }

    public async Task<CategoryDto> UpdateCategoryAsync(Guid id, UpdateCategoryRequest request)
    {
        var category = await _context.Categories.FirstOrDefaultAsync(c => c.Id == id)
            ?? throw new NotFoundException("Category not found.");

        if (await _context.Categories.AnyAsync(c => c.Name == request.Name && c.Id != id))
            throw new BusinessRuleViolationException($"Category with name '{request.Name}' already exists.");

        if (await _context.Categories.AnyAsync(c => c.Slug == request.Slug && c.Id != id))
            throw new BusinessRuleViolationException($"Category with slug '{request.Slug}' already exists.");

        category.Name = request.Name;
        category.Slug = request.Slug;
        category.Description = request.Description;
        await _context.SaveChangesAsync();

        return MapCategory(category);
    }

    public async Task<CategoryDto> DeactivateCategoryAsync(Guid id)
    {
        var category = await _context.Categories.FirstOrDefaultAsync(c => c.Id == id)
            ?? throw new NotFoundException("Category not found.");

        if (!category.IsActive)
            return MapCategory(category);

        category.IsActive = false;
        await _context.SaveChangesAsync();

        return MapCategory(category);
    }

    // ==================== DTO Mappers ====================

    private static SchoolDto MapSchool(School s) => new()
    {
        Id = s.Id,
        Name = s.Name,
        ShortName = s.ShortName,
        City = s.City
    };

    private static AreaDto MapArea(Area a) => new()
    {
        Id = a.Id,
        Name = a.Name,
        City = a.City,
        Description = a.Description
    };

    private static CategoryDto MapCategory(Category c) => new()
    {
        Id = c.Id,
        Name = c.Name,
        Slug = c.Slug,
        Description = c.Description
    };
}
