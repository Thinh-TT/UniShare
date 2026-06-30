using Microsoft.EntityFrameworkCore;
using UniShare.API.Models.Entities;

namespace UniShare.API.Data;

public static class SeedData
{
    // Deterministic GUIDs for seed data consistency
    private static readonly DateTime SeedTime = new(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

    public static void Seed(ModelBuilder modelBuilder)
    {
        SeedSchools(modelBuilder);
        SeedAreas(modelBuilder);
        SeedCategories(modelBuilder);
        SeedTags(modelBuilder);
    }

    private static void SeedSchools(ModelBuilder modelBuilder)
    {
        var schools = new[]
        {
            // TP. Hồ Chí Minh
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000011"), Name = "Đại học Bách Khoa TP.HCM", ShortName = "HCMUT", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000012"), Name = "Đại học Khoa học Tự nhiên TP.HCM", ShortName = "HCMUS", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000013"), Name = "Đại học Kinh tế TP.HCM", ShortName = "UEH", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000014"), Name = "Đại học Sư phạm TP.HCM", ShortName = "HCMUE", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000015"), Name = "Đại học Nông Lâm TP.HCM", ShortName = "NLU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000016"), Name = "Đại học Công nghệ Thông tin", ShortName = "UIT", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000017"), Name = "Đại học Y Dược TP.HCM", ShortName = "UMP", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000018"), Name = "Đại học Kiến Trúc TP.HCM", ShortName = "UAH", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000019"), Name = "Đại học Công nghiệp TP.HCM", ShortName = "IUH", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000020"), Name = "Đại học Mở TP.HCM", ShortName = "OU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000021"), Name = "Đại học Sài Gòn", ShortName = "SGU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000022"), Name = "Đại học Văn Lang", ShortName = "VLU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000023"), Name = "Đại học Tài chính - Marketing", ShortName = "UFM", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000024"), Name = "Đại học Nguyễn Tất Thành", ShortName = "NTTU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000025"), Name = "Đại học Hoa Sen", ShortName = "HSU", City = "TP. Hồ Chí Minh", IsActive = true, CreatedAt = SeedTime },
        };

        modelBuilder.Entity<School>().HasData(schools);
    }

    private static void SeedAreas(ModelBuilder modelBuilder)
    {
        var areas = new[]
        {
            // TP. Hồ Chí Minh
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000009"), Name = "Quận 1", City = "TP. Hồ Chí Minh", Description = "Khu vực trung tâm Quận 1", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000a"), Name = "Quận 3", City = "TP. Hồ Chí Minh", Description = "Khu vực Quận 3", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000b"), Name = "Quận 5", City = "TP. Hồ Chí Minh", Description = "Khu vực Quận 5 (gần Đại học Sư phạm, Đại học Y Dược)", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000c"), Name = "Quận 10", City = "TP. Hồ Chí Minh", Description = "Khu vực Quận 10 (gần Đại học Bách Khoa)", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000d"), Name = "Quận Thủ Đức", City = "TP. Hồ Chí Minh", Description = "Khu vực Thủ Đức (khu vực ĐHQG TP.HCM)", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000e"), Name = "Bình Thạnh", City = "TP. Hồ Chí Minh", Description = "Khu vực Bình Thạnh (gần Đại học Ngoại thương, Đại học Văn Lang)", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-00000000000f"), Name = "Tân Bình", City = "TP. Hồ Chí Minh", Description = "Khu vực Tân Bình", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000010"), Name = "Gò Vấp", City = "TP. Hồ Chí Minh", Description = "Khu vực Gò Vấp", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000011"), Name = "Quận 7", City = "TP. Hồ Chí Minh", Description = "Khu vực Quận 7", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000012"), Name = "Phú Nhuận", City = "TP. Hồ Chí Minh", Description = "Khu vực Phú Nhuận", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000013"), Name = "Nhà Bè", City = "TP. Hồ Chí Minh", Description = "Khu vực Nhà Bè (gần KTX ĐHQG TP.HCM)", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000014"), Name = "Hóc Môn", City = "TP. Hồ Chí Minh", Description = "Khu vực Hóc Môn", IsActive = true, CreatedAt = SeedTime },
        };

        modelBuilder.Entity<Area>().HasData(areas);
    }

    private static void SeedCategories(ModelBuilder modelBuilder)
    {
        var categories = new[]
        {
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000001"), Name = "Máy tính", Slug = "may-tinh", Description = "Máy tính bỏ túi, máy tính khoa học", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000002"), Name = "Sách giáo trình", Slug = "sach-giao-trinh", Description = "Sách giáo trình, sách tham khảo", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000003"), Name = "Thiết bị thí nghiệm", Slug = "thiet-bi-thi-nghiem", Description = "Dụng cụ thí nghiệm, thiết bị phòng lab", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000004"), Name = "Máy ảnh", Slug = "may-anh", Description = "Máy ảnh, ống kính, phụ kiện", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000005"), Name = "Đồ tốt nghiệp", Slug = "do-tot-nghiep", Description = "Áo cử nhân, lễ phục tốt nghiệp", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000006"), Name = "Dụng cụ thể thao", Slug = "dung-cu-the-thao", Description = "Dụng cụ thể thao, đồ tập luyện", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000007"), Name = "Nhạc cụ", Slug = "nhac-cu", Description = "Nhạc cụ các loại", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000008"), Name = "Dụng cụ vẽ", Slug = "dung-cu-ve", Description = "Dụng cụ vẽ, mỹ thuật, kiến trúc", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000009"), Name = "Thiết bị điện tử", Slug = "thiet-bi-dien-tu", Description = "Laptop, tablet, thiết bị điện tử", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000010"), Name = "Đồ gia dụng", Slug = "do-gia-dung", Description = "Đồ gia dụng thiết yếu cho sinh viên", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000011"), Name = "Xe đạp", Slug = "xe-dap", Description = "Xe đạp, xe điện", IsActive = true, CreatedAt = SeedTime },
            new Category { Id = Guid.Parse("30000000-0000-0000-0000-000000000012"), Name = "Khác", Slug = "khac", Description = "Các mặt hàng khác", IsActive = true, CreatedAt = SeedTime },
        };

        modelBuilder.Entity<Category>().HasData(categories);
    }

    private static void SeedTags(ModelBuilder modelBuilder)
    {
        var tags = new[]
        {
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000001"), Name = "casio", Slug = "casio", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000002"), Name = "texas-instruments", Slug = "texas-instruments", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000003"), Name = "textbook", Slug = "textbook", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000004"), Name = "calculator", Slug = "calculator", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000005"), Name = "canon", Slug = "canon", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000006"), Name = "nikon", Slug = "nikon", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000007"), Name = "sony", Slug = "sony", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000008"), Name = "laptop", Slug = "laptop", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000009"), Name = "ipad", Slug = "ipad", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000010"), Name = "guitar", Slug = "guitar", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000011"), Name = "bicycle", Slug = "bicycle", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000012"), Name = "camera", Slug = "camera", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000013"), Name = "gown", Slug = "gown", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000014"), Name = "microscope", Slug = "microscope", CreatedAt = SeedTime },
            new Tag { Id = Guid.Parse("40000000-0000-0000-0000-000000000015"), Name = "chemistry", Slug = "chemistry", CreatedAt = SeedTime },
        };

        modelBuilder.Entity<Tag>().HasData(tags);
    }
}
