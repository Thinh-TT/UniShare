using UniShare.API.Models.DTOs.Metadata;

namespace UniShare.API.Services.Interfaces;

public interface IMetadataService
{
    Task<List<SchoolDto>> GetActiveSchoolsAsync();
    Task<List<AreaDto>> GetActiveAreasAsync();
    Task<List<CategoryDto>> GetActiveCategoriesAsync();
    Task<(List<TagDto> Items, int TotalCount)> GetTagsAsync(string? keyword = null, int page = 1, int pageSize = 20);
}
