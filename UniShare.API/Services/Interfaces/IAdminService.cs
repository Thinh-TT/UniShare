using UniShare.API.Models.DTOs.Metadata;

namespace UniShare.API.Services.Interfaces;

public interface IAdminService
{
    // Schools
    Task<SchoolDto> CreateSchoolAsync(CreateSchoolRequest request);
    Task<SchoolDto> UpdateSchoolAsync(Guid id, UpdateSchoolRequest request);
    Task<SchoolDto> DeactivateSchoolAsync(Guid id);

    // Areas
    Task<AreaDto> CreateAreaAsync(CreateAreaRequest request);
    Task<AreaDto> UpdateAreaAsync(Guid id, UpdateAreaRequest request);
    Task<AreaDto> DeactivateAreaAsync(Guid id);

    // Categories
    Task<CategoryDto> CreateCategoryAsync(CreateCategoryRequest request);
    Task<CategoryDto> UpdateCategoryAsync(Guid id, UpdateCategoryRequest request);
    Task<CategoryDto> DeactivateCategoryAsync(Guid id);
}
