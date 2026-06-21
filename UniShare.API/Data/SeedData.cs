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
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000001"), Name = "Đại học Bách Khoa Hà Nội", ShortName = "HUST", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000002"), Name = "Đại học Quốc Gia Hà Nội", ShortName = "VNU", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000003"), Name = "Đại học Kinh Tế Quốc Dân", ShortName = "NEU", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000004"), Name = "Đại học Xây Dựng", ShortName = "NUCE", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000005"), Name = "Học viện Công nghệ Bưu chính Viễn thông", ShortName = "PTIT", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000006"), Name = "Đại học Thương Mại", ShortName = "TMU", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000007"), Name = "Đại học Sư Phạm Hà Nội", ShortName = "HNUE", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000008"), Name = "Đại học Ngoại Thương", ShortName = "FTU", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000009"), Name = "Đại học Luật Hà Nội", ShortName = "HLU", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
            new School { Id = Guid.Parse("10000000-0000-0000-0000-000000000010"), Name = "Đại học Công Nghiệp Hà Nội", ShortName = "HAUI", City = "Hà Nội", IsActive = true, CreatedAt = SeedTime },
        };

        modelBuilder.Entity<School>().HasData(schools);
    }

    private static void SeedAreas(ModelBuilder modelBuilder)
    {
        var areas = new[]
        {
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000001"), Name = "Ký túc xá Mỹ Đình", City = "Hà Nội", Description = "Khu ký túc xá sinh viên Mỹ Đình", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000002"), Name = "Cầu Giấy", City = "Hà Nội", Description = "Khu vực Cầu Giấy", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000003"), Name = "Đống Đa", City = "Hà Nội", Description = "Khu vực Đống Đa", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000004"), Name = "Hai Bà Trưng", City = "Hà Nội", Description = "Khu vực Hai Bà Trưng", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000005"), Name = "Thanh Xuân", City = "Hà Nội", Description = "Khu vực Thanh Xuân", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000006"), Name = "Hoàn Kiếm", City = "Hà Nội", Description = "Khu vực trung tâm Hoàn Kiếm", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000007"), Name = "Từ Liêm", City = "Hà Nội", Description = "Khu vực Bắc Từ Liêm và Nam Từ Liêm", IsActive = true, CreatedAt = SeedTime },
            new Area { Id = Guid.Parse("20000000-0000-0000-0000-000000000008"), Name = "Hà Đông", City = "Hà Nội", Description = "Khu vực Hà Đông", IsActive = true, CreatedAt = SeedTime },
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
