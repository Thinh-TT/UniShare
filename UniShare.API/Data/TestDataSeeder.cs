using Microsoft.EntityFrameworkCore;
using UniShare.API.Models.Entities;
using UniShare.API.Models.Enums;
using UniShare.API.Services.Interfaces;

namespace UniShare.API.Data;

/// <summary>
/// Seeds comprehensive test data for development and testing purposes.
///
/// Usage: Inject this service and call SeedAsync() once during app startup in Development environment.
/// Example in Program.cs:
///   if (app.Environment.IsDevelopment())
///   {
///       using var scope = app.Services.CreateScope();
///       var seeder = scope.ServiceProvider.GetRequiredService<TestDataSeeder>();
///       await seeder.SeedAsync();
///   }
///
/// All test passwords are: Test@123
/// All IDs are deterministic GUIDs for consistent test data across runs.
/// </summary>
public class TestDataSeeder
{
    private readonly AppDbContext _context;
    private readonly IPasswordHasher _passwordHasher;

    // ============================================================
    // Base timestamps for realistic chronological data
    // ============================================================
    private static readonly DateTime T0 = new(2026, 05, 01, 08, 00, 00, DateTimeKind.Utc); // Earliest - user registration
    private static readonly DateTime T1 = new(2026, 06, 01, 09, 00, 00, DateTimeKind.Utc); // Listings created
    private static readonly DateTime T2 = new(2026, 06, 10, 10, 00, 00, DateTimeKind.Utc); // Interactions start
    private static readonly DateTime T3 = new(2026, 06, 15, 11, 00, 00, DateTimeKind.Utc); // Rental requests
    private static readonly DateTime T4 = new(2026, 06, 20, 12, 00, 00, DateTimeKind.Utc); // Chat & messages
    private static readonly DateTime T5 = new(2026, 06, 25, 13, 00, 00, DateTimeKind.Utc); // Completed transactions
    private static readonly DateTime T6 = new(2026, 06, 28, 14, 00, 00, DateTimeKind.Utc); // Reviews
    private static readonly DateTime T7 = new(2026, 06, 30, 15, 00, 00, DateTimeKind.Utc); // Recent activity

    // ============================================================
    // Reference Data GUIDs (from SeedData.cs - do not modify)
    // ============================================================

    // Schools (HCMC)
    private static readonly Guid SchoolHCMUT = Guid.Parse("10000000-0000-0000-0000-000000000011"); // Bách Khoa
    private static readonly Guid SchoolHCMUS = Guid.Parse("10000000-0000-0000-0000-000000000012"); // KHTN
    private static readonly Guid SchoolUEH   = Guid.Parse("10000000-0000-0000-0000-000000000013"); // Kinh tế
    private static readonly Guid SchoolHCMUE = Guid.Parse("10000000-0000-0000-0000-000000000014"); // Sư phạm
    private static readonly Guid SchoolNLU   = Guid.Parse("10000000-0000-0000-0000-000000000015"); // Nông Lâm
    private static readonly Guid SchoolUIT   = Guid.Parse("10000000-0000-0000-0000-000000000016"); // CNTT
    private static readonly Guid SchoolUMP   = Guid.Parse("10000000-0000-0000-0000-000000000017"); // Y Dược
    private static readonly Guid SchoolIUH   = Guid.Parse("10000000-0000-0000-0000-000000000019"); // Công nghiệp
    private static readonly Guid SchoolHSU   = Guid.Parse("10000000-0000-0000-0000-000000000025"); // Hoa Sen

    // Areas (HCMC)
    private static readonly Guid AreaQ1      = Guid.Parse("20000000-0000-0000-0000-000000000009"); // Quận 1
    private static readonly Guid AreaQ3      = Guid.Parse("20000000-0000-0000-0000-00000000000a"); // Quận 3
    private static readonly Guid AreaQ5      = Guid.Parse("20000000-0000-0000-0000-00000000000b"); // Quận 5
    private static readonly Guid AreaQ10     = Guid.Parse("20000000-0000-0000-0000-00000000000c"); // Quận 10
    private static readonly Guid AreaThuDuc  = Guid.Parse("20000000-0000-0000-0000-00000000000d"); // Thủ Đức
    private static readonly Guid AreaBinhThanh = Guid.Parse("20000000-0000-0000-0000-00000000000e"); // Bình Thạnh
    private static readonly Guid AreaTanBinh = Guid.Parse("20000000-0000-0000-0000-00000000000f"); // Tân Bình
    private static readonly Guid AreaGoVap   = Guid.Parse("20000000-0000-0000-0000-000000000010"); // Gò Vấp
    private static readonly Guid AreaQ7      = Guid.Parse("20000000-0000-0000-0000-000000000011"); // Quận 7

    // Categories
    private static readonly Guid CatCalculator    = Guid.Parse("30000000-0000-0000-0000-000000000001"); // Máy tính
    private static readonly Guid CatTextbook      = Guid.Parse("30000000-0000-0000-0000-000000000002"); // Sách giáo trình
    private static readonly Guid CatLabEquipment  = Guid.Parse("30000000-0000-0000-0000-000000000003"); // Thiết bị thí nghiệm
    private static readonly Guid CatCamera        = Guid.Parse("30000000-0000-0000-0000-000000000004"); // Máy ảnh
    private static readonly Guid CatGraduation    = Guid.Parse("30000000-0000-0000-0000-000000000005"); // Đồ tốt nghiệp
    private static readonly Guid CatSports        = Guid.Parse("30000000-0000-0000-0000-000000000006"); // Dụng cụ thể thao
    private static readonly Guid CatMusic         = Guid.Parse("30000000-0000-0000-0000-000000000007"); // Nhạc cụ
    private static readonly Guid CatArt           = Guid.Parse("30000000-0000-0000-0000-000000000008"); // Dụng cụ vẽ
    private static readonly Guid CatElectronics   = Guid.Parse("30000000-0000-0000-0000-000000000009"); // Thiết bị điện tử
    private static readonly Guid CatHousehold     = Guid.Parse("30000000-0000-0000-0000-000000000010"); // Đồ gia dụng
    private static readonly Guid CatBicycle       = Guid.Parse("30000000-0000-0000-0000-000000000011"); // Xe đạp
    private static readonly Guid CatOther         = Guid.Parse("30000000-0000-0000-0000-000000000012"); // Khác

    // Tags
    private static readonly Guid TagCasio     = Guid.Parse("40000000-0000-0000-0000-000000000001");
    private static readonly Guid TagTexas     = Guid.Parse("40000000-0000-0000-0000-000000000002");
    private static readonly Guid TagTextbook  = Guid.Parse("40000000-0000-0000-0000-000000000003");
    private static readonly Guid TagCalculator= Guid.Parse("40000000-0000-0000-0000-000000000004");
    private static readonly Guid TagCanon     = Guid.Parse("40000000-0000-0000-0000-000000000005");
    private static readonly Guid TagNikon     = Guid.Parse("40000000-0000-0000-0000-000000000006");
    private static readonly Guid TagSony      = Guid.Parse("40000000-0000-0000-0000-000000000007");
    private static readonly Guid TagLaptop    = Guid.Parse("40000000-0000-0000-0000-000000000008");
    private static readonly Guid TagIpad      = Guid.Parse("40000000-0000-0000-0000-000000000009");
    private static readonly Guid TagGuitar    = Guid.Parse("40000000-0000-0000-0000-000000000010");
    private static readonly Guid TagBicycle   = Guid.Parse("40000000-0000-0000-0000-000000000011");
    private static readonly Guid TagCamera    = Guid.Parse("40000000-0000-0000-0000-000000000012");
    private static readonly Guid TagGown      = Guid.Parse("40000000-0000-0000-0000-000000000013");
    private static readonly Guid TagMicroscope= Guid.Parse("40000000-0000-0000-0000-000000000014");
    private static readonly Guid TagChemistry = Guid.Parse("40000000-0000-0000-0000-000000000015");

    // ============================================================
    // Test User GUIDs
    // ============================================================
    private static readonly Guid UserAdmin    = Guid.Parse("A0000000-0000-0000-0000-000000000001");
    private static readonly Guid UserAn       = Guid.Parse("A0000000-0000-0000-0000-000000000002");
    private static readonly Guid UserBinh     = Guid.Parse("A0000000-0000-0000-0000-000000000003");
    private static readonly Guid UserCuong    = Guid.Parse("A0000000-0000-0000-0000-000000000004");
    private static readonly Guid UserDung     = Guid.Parse("A0000000-0000-0000-0000-000000000005");
    private static readonly Guid UserEm       = Guid.Parse("A0000000-0000-0000-0000-000000000006");
    private static readonly Guid UserPhuong   = Guid.Parse("A0000000-0000-0000-0000-000000000007");
    private static readonly Guid UserGiang    = Guid.Parse("A0000000-0000-0000-0000-000000000008");
    private static readonly Guid UserHuong    = Guid.Parse("A0000000-0000-0000-0000-000000000009");
    private static readonly Guid UserKhanh    = Guid.Parse("A0000000-0000-0000-0000-00000000000A");

    // ============================================================
    // Test Listing GUIDs (20 listings)
    // ============================================================
    private static readonly Guid Listing01 = Guid.Parse("B0000000-0000-0000-0000-000000000001");
    private static readonly Guid Listing02 = Guid.Parse("B0000000-0000-0000-0000-000000000002");
    private static readonly Guid Listing03 = Guid.Parse("B0000000-0000-0000-0000-000000000003");
    private static readonly Guid Listing04 = Guid.Parse("B0000000-0000-0000-0000-000000000004");
    private static readonly Guid Listing05 = Guid.Parse("B0000000-0000-0000-0000-000000000005");
    private static readonly Guid Listing06 = Guid.Parse("B0000000-0000-0000-0000-000000000006");
    private static readonly Guid Listing07 = Guid.Parse("B0000000-0000-0000-0000-000000000007");
    private static readonly Guid Listing08 = Guid.Parse("B0000000-0000-0000-0000-000000000008");
    private static readonly Guid Listing09 = Guid.Parse("B0000000-0000-0000-0000-000000000009");
    private static readonly Guid Listing10 = Guid.Parse("B0000000-0000-0000-0000-00000000000A");
    private static readonly Guid Listing11 = Guid.Parse("B0000000-0000-0000-0000-00000000000B");
    private static readonly Guid Listing12 = Guid.Parse("B0000000-0000-0000-0000-00000000000C");
    private static readonly Guid Listing13 = Guid.Parse("B0000000-0000-0000-0000-00000000000D");
    private static readonly Guid Listing14 = Guid.Parse("B0000000-0000-0000-0000-00000000000E");
    private static readonly Guid Listing15 = Guid.Parse("B0000000-0000-0000-0000-00000000000F");
    private static readonly Guid Listing16 = Guid.Parse("B0000000-0000-0000-0000-000000000010");
    private static readonly Guid Listing17 = Guid.Parse("B0000000-0000-0000-0000-000000000011");
    private static readonly Guid Listing18 = Guid.Parse("B0000000-0000-0000-0000-000000000012");
    private static readonly Guid Listing19 = Guid.Parse("B0000000-0000-0000-0000-000000000013");
    private static readonly Guid Listing20 = Guid.Parse("B0000000-0000-0000-0000-000000000014");

    // ============================================================
    // Test Rental Request GUIDs (10 requests)
    // ============================================================
    private static readonly Guid Request01 = Guid.Parse("F0000000-0000-0000-0000-000000000001");
    private static readonly Guid Request02 = Guid.Parse("F0000000-0000-0000-0000-000000000002");
    private static readonly Guid Request03 = Guid.Parse("F0000000-0000-0000-0000-000000000003");
    private static readonly Guid Request04 = Guid.Parse("F0000000-0000-0000-0000-000000000004");
    private static readonly Guid Request05 = Guid.Parse("F0000000-0000-0000-0000-000000000005");
    private static readonly Guid Request06 = Guid.Parse("F0000000-0000-0000-0000-000000000006");
    private static readonly Guid Request07 = Guid.Parse("F0000000-0000-0000-0000-000000000007");
    private static readonly Guid Request08 = Guid.Parse("F0000000-0000-0000-0000-000000000008");
    private static readonly Guid Request09 = Guid.Parse("F0000000-0000-0000-0000-000000000009");
    private static readonly Guid Request10 = Guid.Parse("F0000000-0000-0000-0000-00000000000A");

    // ============================================================
    // Test Conversation GUIDs (8 conversations)
    // ============================================================
    private static readonly Guid Conv01 = Guid.Parse("A2000000-0000-0000-0000-000000000001");
    private static readonly Guid Conv02 = Guid.Parse("A2000000-0000-0000-0000-000000000002");
    private static readonly Guid Conv03 = Guid.Parse("A2000000-0000-0000-0000-000000000003");
    private static readonly Guid Conv04 = Guid.Parse("A2000000-0000-0000-0000-000000000004");
    private static readonly Guid Conv05 = Guid.Parse("A2000000-0000-0000-0000-000000000005");
    private static readonly Guid Conv06 = Guid.Parse("A2000000-0000-0000-0000-000000000006");
    private static readonly Guid Conv07 = Guid.Parse("A2000000-0000-0000-0000-000000000007");
    private static readonly Guid Conv08 = Guid.Parse("A2000000-0000-0000-0000-000000000008");

    public TestDataSeeder(AppDbContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    /// <summary>
    /// Seeds all test data. Skips entities that already exist (checked by ID).
    /// Safe to call multiple times.
    /// </summary>
    public async Task SeedAsync()
    {
        // Order matters due to foreign key dependencies
        await SeedUsersAsync();
        await SeedListingsAsync();
        await SeedListingImagesAsync();
        await SeedListingTagsAsync();
        await SeedUpvotesAsync();
        await SeedCommentsAsync();
        await SeedRentalRequestsAsync();
        await SeedDepositsAsync();
        await SeedConversationsAsync();
        await SeedMessagesAsync();
        await SeedReviewsAsync();
        await SeedNotificationsAsync();

        await _context.SaveChangesAsync();
    }

    // ============================================================
    // 1. USERS - 10 users (1 admin + 9 students)
    //    All passwords: Test@123
    // ============================================================
    private async Task SeedUsersAsync()
    {
        if (await _context.Users.AnyAsync(u => u.Id == UserAdmin))
            return;

        var passwordHash = _passwordHasher.Hash("Test@123");
        var passwordHashadmin = _passwordHasher.Hash("Thinh@123");

        var users = new[]
        {
            // Admin
            new User
            {
                Id = UserAdmin,
                Email = "admin@unishare.test",
                PhoneNumber = "0900000001",
                PasswordHash = passwordHashadmin,
                FullName = "Quản trị viên",
                AvatarUrl = "/avatars/admin.jpg",
                Role = Roles.Admin,
                SchoolId = SchoolUIT,
                AreaId = AreaThuDuc,
                ReputationScore = 0,
                TotalReviews = 0,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0,
                UpdatedAt = T0,
            },
            // Student 1 - IT student at UIT, lives in Thủ Đức
            new User
            {
                Id = UserAn,
                Email = "an.nguyen@unishare.test",
                PhoneNumber = "0900000002",
                PasswordHash = passwordHash,
                FullName = "Nguyễn Văn An",
                AvatarUrl = "/avatars/user_an.jpg",
                Role = Roles.User,
                SchoolId = SchoolUIT,
                AreaId = AreaThuDuc,
                ReputationScore = 105.50m,
                TotalReviews = 3,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(1),
                UpdatedAt = T6,
            },
            // Student 2 - Science student at HCMUS, lives in Quận 5
            new User
            {
                Id = UserBinh,
                Email = "binh.tran@unishare.test",
                PhoneNumber = "0900000003",
                PasswordHash = passwordHash,
                FullName = "Trần Thị Bình",
                AvatarUrl = "/avatars/user_binh.jpg",
                Role = Roles.User,
                SchoolId = SchoolHCMUS,
                AreaId = AreaQ5,
                ReputationScore = 98.00m,
                TotalReviews = 2,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(2),
                UpdatedAt = T6.AddDays(-1),
            },
            // Student 3 - Engineering student at HCMUT, lives in Quận 10
            new User
            {
                Id = UserCuong,
                Email = "cuong.le@unishare.test",
                PhoneNumber = "0900000004",
                PasswordHash = passwordHash,
                FullName = "Lê Văn Cường",
                AvatarUrl = "/avatars/user_cuong.jpg",
                Role = Roles.User,
                SchoolId = SchoolHCMUT,
                AreaId = AreaQ10,
                ReputationScore = 110.00m,
                TotalReviews = 5,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(3),
                UpdatedAt = T6,
            },
            // Student 4 - Economics student at UEH, lives in Bình Thạnh
            new User
            {
                Id = UserDung,
                Email = "dung.pham@unishare.test",
                PhoneNumber = "0900000005",
                PasswordHash = passwordHash,
                FullName = "Phạm Thị Dung",
                AvatarUrl = "/avatars/user_dung.jpg",
                Role = Roles.User,
                SchoolId = SchoolUEH,
                AreaId = AreaBinhThanh,
                ReputationScore = 100.00m,
                TotalReviews = 0,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(4),
                UpdatedAt = T0.AddDays(4),
            },
            // Student 5 - Medical student at UMP, lives in Quận 5
            new User
            {
                Id = UserEm,
                Email = "em.hoang@unishare.test",
                PhoneNumber = "0900000006",
                PasswordHash = passwordHash,
                FullName = "Hoàng Văn Em",
                AvatarUrl = "/avatars/user_em.jpg",
                Role = Roles.User,
                SchoolId = SchoolUMP,
                AreaId = AreaQ5,
                ReputationScore = 102.00m,
                TotalReviews = 1,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(5),
                UpdatedAt = T5,
            },
            // Student 6 - Education student at HCMUE, lives in Quận 3
            new User
            {
                Id = UserPhuong,
                Email = "phuong.vu@unishare.test",
                PhoneNumber = "0900000007",
                PasswordHash = passwordHash,
                FullName = "Vũ Thị Phương",
                AvatarUrl = "/avatars/user_phuong.jpg",
                Role = Roles.User,
                SchoolId = SchoolHCMUE,
                AreaId = AreaQ3,
                ReputationScore = 95.00m,
                TotalReviews = 1,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(6),
                UpdatedAt = T6.AddDays(-2),
            },
            // Student 7 - Industrial University student, lives in Gò Vấp
            new User
            {
                Id = UserGiang,
                Email = "giang.dang@unishare.test",
                PhoneNumber = "0900000008",
                PasswordHash = passwordHash,
                FullName = "Đặng Văn Giang",
                AvatarUrl = "/avatars/user_giang.jpg",
                Role = Roles.User,
                SchoolId = SchoolIUH,
                AreaId = AreaGoVap,
                ReputationScore = 100.00m,
                TotalReviews = 0,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(7),
                UpdatedAt = T0.AddDays(7),
            },
            // Student 8 - Hoa Sen student, lives in Quận 1
            new User
            {
                Id = UserHuong,
                Email = "huong.bui@unishare.test",
                PhoneNumber = "0900000009",
                PasswordHash = passwordHash,
                FullName = "Bùi Thị Hương",
                AvatarUrl = "/avatars/user_huong.jpg",
                Role = Roles.User,
                SchoolId = SchoolHSU,
                AreaId = AreaQ1,
                ReputationScore = 108.00m,
                TotalReviews = 4,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(8),
                UpdatedAt = T6,
            },
            // Student 9 - Agriculture student at NLU, lives in Thủ Đức
            new User
            {
                Id = UserKhanh,
                Email = "khanh.ngo@unishare.test",
                PhoneNumber = "0900000010",
                PasswordHash = passwordHash,
                FullName = "Ngô Văn Khánh",
                AvatarUrl = "/avatars/user_khanh.jpg",
                Role = Roles.User,
                SchoolId = SchoolNLU,
                AreaId = AreaThuDuc,
                ReputationScore = 100.00m,
                TotalReviews = 0,
                IsVerified = true,
                IsActive = true,
                CreatedAt = T0.AddDays(9),
                UpdatedAt = T0.AddDays(9),
            },
        };

        _context.Users.AddRange(users);
    }

    // ============================================================
    // 2. LISTINGS - 20 listings across various categories
    //    Mix of Rent (cho thuê) and Borrow (cho mượn)
    //    Various statuses: Available, Reserved, InUse, Closed
    // ============================================================
    private async Task SeedListingsAsync()
    {
        if (await _context.Listings.AnyAsync(l => l.Id == Listing01))
            return;

        var listings = new[]
        {
            // ── LISTING 01: Máy tính Casio cho mượn (Available) ──
            new Listing
            {
                Id = Listing01,
                OwnerId = UserAn,
                CategoryId = CatCalculator,
                SchoolId = SchoolUIT,
                AreaId = AreaThuDuc,
                Title = "Máy tính Casio fx-570VN PLUS - Cho mượn miễn phí",
                Description = "Máy tính còn mới 95%, đầy đủ chức năng. Mình không dùng nữa sau khi thi xong Giải tích. Cho các bạn UIT mượn dùng trong 1-2 tuần. Pin vẫn còn tốt.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 200000,
                ConditionNote = "Máy còn mới, không trầy xước. Pin còn tốt.",
                ViewCount = 156,
                UpvoteCount = 12,
                CommentCount = 3,
                CreatedAt = T1,
                UpdatedAt = T2,
            },
            // ── LISTING 02: Giáo trình cho thuê (Available) ──
            new Listing
            {
                Id = Listing02,
                OwnerId = UserBinh,
                CategoryId = CatTextbook,
                SchoolId = SchoolHCMUS,
                AreaId = AreaQ5,
                Title = "Giáo trình Toán Cao Cấp A1 - ĐH KHTN",
                Description = "Giáo trình Toán Cao Cấp A1 dành cho sinh viên năm nhất KHTN. Sách còn nguyên vẹn, không bị ghi chú. Cho thuê theo kỳ học.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 5000,
                DepositAmount = 100000,
                ConditionNote = "Sách sạch, không ghi chú, bìa còn đẹp.",
                ViewCount = 89,
                UpvoteCount = 5,
                CommentCount = 1,
                CreatedAt = T1.AddDays(1),
                UpdatedAt = T2,
            },
            // ── LISTING 03: Kính hiển vi sinh học cho thuê (Available) ──
            new Listing
            {
                Id = Listing03,
                OwnerId = UserEm,
                CategoryId = CatLabEquipment,
                SchoolId = SchoolUMP,
                AreaId = AreaQ5,
                Title = "Kính hiển vi quang học - Cho thuê theo buổi",
                Description = "Kính hiển vi quang học dùng cho môn Sinh học tế bào. Độ phóng đại 400x-1000x. Còn hoạt động tốt, thích hợp cho sinh viên Y Khoa cần thực hành thêm.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 30000,
                DepositAmount = 500000,
                ConditionNote = "Kính hoạt động tốt, đã vệ sinh thấu kính. Cần bảo quản trong hộp khi không sử dụng.",
                ViewCount = 45,
                UpvoteCount = 3,
                CommentCount = 0,
                CreatedAt = T1.AddDays(2),
                UpdatedAt = T1.AddDays(2),
            },
            // ── LISTING 04: Máy ảnh Canon cho thuê (Reserved - đã có người đặt) ──
            new Listing
            {
                Id = Listing04,
                OwnerId = UserCuong,
                CategoryId = CatCamera,
                SchoolId = SchoolHCMUT,
                AreaId = AreaQ10,
                Title = "Máy ảnh Canon EOS M50 - Cho thuê chụp đồ án",
                Description = "Máy ảnh Canon EOS M50 kèm lens kit 15-45mm. Phù hợp cho các bạn Kiến trúc, Thiết kế cần chụp mô hình đồ án. Pin sạc đầy đủ, thẻ nhớ 32GB đi kèm.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Reserved,
                PricePerDay = 80000,
                DepositAmount = 2000000,
                ConditionNote = "Máy đã dùng 1 năm, hoạt động bình thường. Không bị rơi vỡ, màn hình LCD không bị trầy.",
                ViewCount = 234,
                UpvoteCount = 18,
                CommentCount = 5,
                CreatedAt = T1.AddDays(3),
                UpdatedAt = T3.AddDays(1),
            },
            // ── LISTING 05: Áo tốt nghiệp cho thuê (Available) ──
            new Listing
            {
                Id = Listing05,
                OwnerId = UserHuong,
                CategoryId = CatGraduation,
                SchoolId = SchoolHSU,
                AreaId = AreaQ1,
                Title = "Áo cử nhân Hoa Sen size M - Cho thuê chụp ảnh tốt nghiệp",
                Description = "Áo cử nhân đại học Hoa Sen size M (nữ). Mới mua chỉ mặc 1 lần chụp ảnh. Còn rất mới và sạch sẽ. Phù hợp cho các bạn nữ cao 1m55-1m65.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 50000,
                DepositAmount = 300000,
                ConditionNote = "Áo còn mới, đã giặt sạch, ủi phẳng phiu.",
                ViewCount = 67,
                UpvoteCount = 4,
                CommentCount = 2,
                CreatedAt = T1.AddDays(4),
                UpdatedAt = T2,
            },
            // ── LISTING 06: Vợt cầu lông cho mượn (Available) ──
            new Listing
            {
                Id = Listing06,
                OwnerId = UserGiang,
                CategoryId = CatSports,
                SchoolId = SchoolIUH,
                AreaId = AreaGoVap,
                Title = "Cặp vợt cầu lông Yonex - Cho mượn đánh tập",
                Description = "2 cây vợt cầu lông Yonex Nanoflare, còn tốt, lưới căng. Có thể mượn lẻ hoặc cả cặp. Có sẵn 1 ống cầu để các bạn dùng chung.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 300000,
                ConditionNote = "Vợt còn tốt, lưới căng vừa phải. Không bị cong vênh.",
                ViewCount = 43,
                UpvoteCount = 7,
                CommentCount = 1,
                CreatedAt = T1.AddDays(5),
                UpdatedAt = T2,
            },
            // ── LISTING 07: Đàn guitar acoustic cho mượn (Available) ──
            new Listing
            {
                Id = Listing07,
                OwnerId = UserPhuong,
                CategoryId = CatMusic,
                SchoolId = SchoolHCMUE,
                AreaId = AreaQ3,
                Title = "Đàn guitar acoustic Yamaha F310 - Cho mượn tập chơi",
                Description = "Đàn guitar acoustic Yamaha F310, dây còn tốt, âm thanh ấm. Phù hợp cho các bạn mới tập chơi hoặc cần đàn để biểu diễn văn nghệ khoa. Mượn tối đa 2 tuần.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 500000,
                ConditionNote = "Đàn đã qua sử dụng nhưng còn tốt. Dây số 3 hơi cũ, có thể thay nếu cần.",
                ViewCount = 102,
                UpvoteCount = 15,
                CommentCount = 3,
                CreatedAt = T1.AddDays(6),
                UpdatedAt = T2,
            },
            // ── LISTING 08: Bộ vẽ kỹ thuật cho mượn (Available) ──
            new Listing
            {
                Id = Listing08,
                OwnerId = UserCuong,
                CategoryId = CatArt,
                SchoolId = SchoolHCMUT,
                AreaId = AreaQ10,
                Title = "Bộ dụng cụ vẽ kỹ thuật - Cho mượn làm đồ án",
                Description = "Bộ dụng cụ vẽ kỹ thuật gồm thước T, thước dẻo, compa, bút chì Kim Tín các loại. Đầy đủ cho một đồ án Kiến trúc/Kỹ thuật. Mượn theo thời gian làm đồ án (2-4 tuần).",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 200000,
                ConditionNote = "Dụng cụ còn tốt, compa hơi lỏng nhưng vẫn dùng được.",
                ViewCount = 78,
                UpvoteCount = 9,
                CommentCount = 0,
                CreatedAt = T1.AddDays(7),
                UpdatedAt = T1.AddDays(7),
            },
            // ── LISTING 09: Laptop Dell cho thuê (InUse - đang cho thuê) ──
            new Listing
            {
                Id = Listing09,
                OwnerId = UserAn,
                CategoryId = CatElectronics,
                SchoolId = SchoolUIT,
                AreaId = AreaThuDuc,
                Title = "Laptop Dell Inspiron 15 - Cho thuê làm đồ án lập trình",
                Description = "Laptop Dell Inspiron 15, Core i5-1135G7, RAM 8GB, SSD 256GB. Cài sẵn Visual Studio Code, Android Studio, IntelliJ. Phù hợp làm đồ án lập trình.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.InUse,
                PricePerDay = 60000,
                DepositAmount = 3000000,
                ConditionNote = "Laptop hoạt động tốt, pin còn khoảng 3 tiếng. Bàn phím hơi bóng nhưng vẫn gõ tốt.",
                ViewCount = 312,
                UpvoteCount = 22,
                CommentCount = 7,
                CreatedAt = T1.AddDays(8),
                UpdatedAt = T3.AddDays(3),
            },
            // ── LISTING 10: Nồi cơm điện cho thuê (Available) ──
            new Listing
            {
                Id = Listing10,
                OwnerId = UserDung,
                CategoryId = CatHousehold,
                SchoolId = SchoolUEH,
                AreaId = AreaBinhThanh,
                Title = "Nồi cơm điện Electrolux 1.2L - Cho thuê ngắn hạn KTX",
                Description = "Nồi cơm điện mini Electrolux 1.2L, phù hợp nấu 2-3 người ăn. Còn mới, đã vệ sinh sạch sẽ. Cho thuê cho các bạn ở KTX cần nấu ăn trong thời gian ngắn.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 10000,
                DepositAmount = 200000,
                ConditionNote = "Nồi còn mới 90%, lòng nồi không trầy, dây điện còn tốt.",
                ViewCount = 56,
                UpvoteCount = 3,
                CommentCount = 1,
                CreatedAt = T1.AddDays(9),
                UpdatedAt = T2,
            },
            // ── LISTING 11: Xe đạp cho thuê dài hạn (Available) ──
            new Listing
            {
                Id = Listing11,
                OwnerId = UserKhanh,
                CategoryId = CatBicycle,
                SchoolId = SchoolNLU,
                AreaId = AreaThuDuc,
                Title = "Xe đạp Martin 107 - Cho thuê theo tháng",
                Description = "Xe đạp thể thao Martin 107, phanh đĩa, bánh 27.5 inch. Xe còn chạy tốt, lốp mới thay. Phù hợp đi lại trong khu vực Thủ Đức, ĐHQG.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 15000,
                DepositAmount = 1000000,
                ConditionNote = "Xe chạy tốt, phanh nhạy. Có thể điều chỉnh yên xe theo chiều cao.",
                ViewCount = 187,
                UpvoteCount = 14,
                CommentCount = 4,
                CreatedAt = T1.AddDays(10),
                UpdatedAt = T2.AddDays(1),
            },
            // ── LISTING 12: Bút vẽ Wacom cho thuê (Available) ──
            new Listing
            {
                Id = Listing12,
                OwnerId = UserHuong,
                CategoryId = CatOther,
                SchoolId = SchoolHSU,
                AreaId = AreaQ1,
                Title = "Bảng vẽ điện tử Wacom Intuos - Cho thuê làm đồ án thiết kế",
                Description = "Bảng vẽ Wacom Intuos S (CTL-4100). Còn mới, dùng cho vẽ digital, thiết kế đồ họa. Tặng kèm 2 ngòi bút dự phòng.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 25000,
                DepositAmount = 800000,
                ConditionNote = "Bảng còn mới, không trầy xước mặt vẽ. Cáp USB đi kèm.",
                ViewCount = 93,
                UpvoteCount = 8,
                CommentCount = 2,
                CreatedAt = T1.AddDays(11),
                UpdatedAt = T2,
            },
            // ── LISTING 13: Sách Giải tích cho mượn (Closed - đã hết hạn) ──
            new Listing
            {
                Id = Listing13,
                OwnerId = UserBinh,
                CategoryId = CatTextbook,
                SchoolId = SchoolHCMUS,
                AreaId = AreaQ5,
                Title = "Sách Giải Tích 2 - ĐH KHTN - Đã cho mượn xong",
                Description = "Sách Giải Tích 2 dành cho sinh viên năm 2. Đã cho mượn xong trong học kỳ trước. Sách còn nhưng có highlight vài chỗ.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Closed,
                PricePerDay = 0,
                DepositAmount = 50000,
                ConditionNote = "Sách đã qua sử dụng, có highlight, vẫn đọc được bình thường.",
                ViewCount = 45,
                UpvoteCount = 2,
                CommentCount = 0,
                CreatedAt = T0.AddDays(30),
                UpdatedAt = T5,
            },
            // ── LISTING 14: Máy tính Texas Instruments cho thuê (Available) ──
            new Listing
            {
                Id = Listing14,
                OwnerId = UserCuong,
                CategoryId = CatCalculator,
                SchoolId = SchoolHCMUT,
                AreaId = AreaQ10,
                Title = "Máy tính TI-84 Plus CE - Cho thuê thi cuối kỳ",
                Description = "Máy tính đồ thị TI-84 Plus CE, hỗ trợ vẽ đồ thị, tính toán ma trận. Phù hợp cho sinh viên thi Đại số tuyến tính, Xác suất thống kê. Pin sạc USB.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 15000,
                DepositAmount = 500000,
                ConditionNote = "Máy còn mới 90%, màn hình màu sắc nét. Pin đã sạc đầy.",
                ViewCount = 67,
                UpvoteCount = 6,
                CommentCount = 1,
                CreatedAt = T1.AddDays(12),
                UpdatedAt = T2,
            },
            // ── LISTING 15: Ống nhòm cho mượn đi thực địa (Available) ──
            new Listing
            {
                Id = Listing15,
                OwnerId = UserEm,
                CategoryId = CatOther,
                SchoolId = SchoolUMP,
                AreaId = AreaQ5,
                Title = "Ống nhòm Nikon 10x42 - Cho mượn đi thực địa sinh học",
                Description = "Ống nhòm Nikon Prostaff 10x42, chống nước, phù hợp cho các bạn đi thực địa Sinh học, Lâm nghiệp. Kèm túi đựng và dây đeo.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 1000000,
                ConditionNote = "Ống nhòm còn tốt, thấu kính không trầy. Dây đeo hơi cũ.",
                ViewCount = 34,
                UpvoteCount = 5,
                CommentCount = 0,
                CreatedAt = T1.AddDays(13),
                UpdatedAt = T1.AddDays(13),
            },
            // ── LISTING 16: Bộ dụng cụ thí nghiệm hóa học (Hidden - admin ẩn) ──
            new Listing
            {
                Id = Listing16,
                OwnerId = UserBinh,
                CategoryId = CatLabEquipment,
                SchoolId = SchoolHCMUS,
                AreaId = AreaQ5,
                Title = "Bộ dụng cụ thí nghiệm Hóa phân tích",
                Description = "Bộ dụng cụ thí nghiệm Hóa phân tích gồm burette, pipette, erlen, cốc đong. Đầy đủ cho một buổi thí nghiệm.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Hidden,
                PricePerDay = 0,
                DepositAmount = 300000,
                ConditionNote = "Dụng cụ sạch sẽ, đã rửa bằng nước cất.",
                ViewCount = 12,
                UpvoteCount = 0,
                CommentCount = 0,
                CreatedAt = T1.AddDays(14),
                UpdatedAt = T7,
            },
            // ── LISTING 17: Loa bluetooth cho thuê sự kiện (Available) ──
            new Listing
            {
                Id = Listing17,
                OwnerId = UserGiang,
                CategoryId = CatElectronics,
                SchoolId = SchoolIUH,
                AreaId = AreaGoVap,
                Title = "Loa bluetooth JBL Flip 6 - Cho thuê sự kiện khoa",
                Description = "Loa JBL Flip 6, âm thanh to rõ, pin 12 tiếng. Phù hợp cho các buổi sinh hoạt CLB, hội trại, picnic khoa.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 20000,
                DepositAmount = 500000,
                ConditionNote = "Loa còn mới 95%, chống nước IPX7. Kèm dây sạc.",
                ViewCount = 78,
                UpvoteCount = 11,
                CommentCount = 2,
                CreatedAt = T1.AddDays(15),
                UpdatedAt = T2,
            },
            // ── LISTING 18: Xe đạp điện cho thuê (Reserved) ──
            new Listing
            {
                Id = Listing18,
                OwnerId = UserPhuong,
                CategoryId = CatBicycle,
                SchoolId = SchoolHCMUE,
                AreaId = AreaQ3,
                Title = "Xe đạp điện Nijia - Cho thuê đi học",
                Description = "Xe đạp điện Nijia, pin 48V, đi được 40-50km 1 lần sạc. Có đèn pha, còi, gương chiếu hậu đầy đủ.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Reserved,
                PricePerDay = 30000,
                DepositAmount = 2000000,
                ConditionNote = "Xe chạy tốt, pin sạc đầy đủ. Phanh đĩa trước sau. Có sẵn áo mưa trong cốp.",
                ViewCount = 245,
                UpvoteCount = 20,
                CommentCount = 6,
                CreatedAt = T1.AddDays(16),
                UpdatedAt = T3.AddDays(3),
            },
            // ── LISTING 19: Tripod máy ảnh cho mượn (Available) ──
            new Listing
            {
                Id = Listing19,
                OwnerId = UserHuong,
                CategoryId = CatCamera,
                SchoolId = SchoolHSU,
                AreaId = AreaQ1,
                Title = "Chân máy ảnh Tripod Velbon - Cho mượn chụp sản phẩm",
                Description = "Chân máy Velbon CX-440, nhẹ, dễ mang theo. Phù hợp quay video, chụp sản phẩm đồ án thiết kế. Tải trọng tối đa 2kg.",
                ListingType = ListingType.Borrow,
                Status = ListingStatus.Available,
                PricePerDay = 0,
                DepositAmount = 200000,
                ConditionNote = "Chân máy còn tốt, khóa các đoạn vẫn chặt. Có túi đựng.",
                ViewCount = 41,
                UpvoteCount = 3,
                CommentCount = 0,
                CreatedAt = T2,
                UpdatedAt = T2,
            },
            // ── LISTING 20: Đồ tốt nghiệp UMP cho thuê (Available) ──
            new Listing
            {
                Id = Listing20,
                OwnerId = UserEm,
                CategoryId = CatGraduation,
                SchoolId = SchoolUMP,
                AreaId = AreaQ5,
                Title = "Combo áo blouse + ống nghe - Cho thuê đi lâm sàng",
                Description = "Áo blouse trắng size L + ống nghe Littmann Classic III. Phù hợp sinh viên Y đa khoa năm 3-4 đi lâm sàng. Cho thuê theo đợt thực tập 2-4 tuần.",
                ListingType = ListingType.Rent,
                Status = ListingStatus.Available,
                PricePerDay = 20000,
                DepositAmount = 500000,
                ConditionNote = "Áo blouse đã giặt sạch, ủi thẳng. Ống nghe còn tốt, âm thanh rõ.",
                ViewCount = 56,
                UpvoteCount = 4,
                CommentCount = 1,
                CreatedAt = T2.AddDays(1),
                UpdatedAt = T2.AddDays(1),
            },
        };

        _context.Listings.AddRange(listings);
    }

    // ============================================================
    // 3. LISTING IMAGES - Each listing has 1-3 images
    //    Using placeholder URLs
    // ============================================================
    private async Task SeedListingImagesAsync()
    {
        if (await _context.ListingImages.AnyAsync(i => i.Id == Guid.Parse("C0000000-0000-0000-0000-000000000001")))
            return;

        var images = new List<ListingImage>
        {
            // Listing 01: Casio calculator
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000001"), ListingId = Listing01, ImageUrl = "/uploads/listings/casio_fx570vn_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1 },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000002"), ListingId = Listing01, ImageUrl = "/uploads/listings/casio_fx570vn_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1 },

            // Listing 02: Textbook Toán A1
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000003"), ListingId = Listing02, ImageUrl = "/uploads/listings/toan_a1_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(1) },

            // Listing 03: Microscope
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000004"), ListingId = Listing03, ImageUrl = "/uploads/listings/microscope_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(2) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000005"), ListingId = Listing03, ImageUrl = "/uploads/listings/microscope_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(2) },

            // Listing 04: Canon M50
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000006"), ListingId = Listing04, ImageUrl = "/uploads/listings/canon_m50_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(3) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000007"), ListingId = Listing04, ImageUrl = "/uploads/listings/canon_m50_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(3) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000008"), ListingId = Listing04, ImageUrl = "/uploads/listings/canon_m50_03.jpg", DisplayOrder = 3, IsCover = false, CreatedAt = T1.AddDays(3) },

            // Listing 05: Graduation gown HSU
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000009"), ListingId = Listing05, ImageUrl = "/uploads/listings/gown_hsu_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(4) },

            // Listing 06: Badminton rackets
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000A"), ListingId = Listing06, ImageUrl = "/uploads/listings/yonex_racket_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(5) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000B"), ListingId = Listing06, ImageUrl = "/uploads/listings/yonex_racket_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(5) },

            // Listing 07: Guitar Yamaha
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000C"), ListingId = Listing07, ImageUrl = "/uploads/listings/yamaha_f310_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(6) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000D"), ListingId = Listing07, ImageUrl = "/uploads/listings/yamaha_f310_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(6) },

            // Listing 08: Drawing tools
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000E"), ListingId = Listing08, ImageUrl = "/uploads/listings/drawing_tools_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(7) },

            // Listing 09: Dell Laptop
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000000F"), ListingId = Listing09, ImageUrl = "/uploads/listings/dell_inspiron_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(8) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000010"), ListingId = Listing09, ImageUrl = "/uploads/listings/dell_inspiron_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(8) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000011"), ListingId = Listing09, ImageUrl = "/uploads/listings/dell_inspiron_03.jpg", DisplayOrder = 3, IsCover = false, CreatedAt = T1.AddDays(8) },

            // Listing 10: Rice cooker
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000012"), ListingId = Listing10, ImageUrl = "/uploads/listings/electrolux_cooker_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(9) },

            // Listing 11: Bicycle Martin
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000013"), ListingId = Listing11, ImageUrl = "/uploads/listings/martin_bike_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(10) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000014"), ListingId = Listing11, ImageUrl = "/uploads/listings/martin_bike_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(10) },

            // Listing 12: Wacom tablet
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000015"), ListingId = Listing12, ImageUrl = "/uploads/listings/wacom_intuos_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(11) },

            // Listing 13: Textbook (closed)
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000016"), ListingId = Listing13, ImageUrl = "/uploads/listings/giai_tich_2_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T0.AddDays(30) },

            // Listing 14: TI-84 calculator
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000017"), ListingId = Listing14, ImageUrl = "/uploads/listings/ti84_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(12) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000018"), ListingId = Listing14, ImageUrl = "/uploads/listings/ti84_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(12) },

            // Listing 15: Binoculars
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000019"), ListingId = Listing15, ImageUrl = "/uploads/listings/nikon_binoculars_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(13) },

            // Listing 16: Chemistry lab equipment (hidden)
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001A"), ListingId = Listing16, ImageUrl = "/uploads/listings/chem_lab_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(14) },

            // Listing 17: JBL speaker
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001B"), ListingId = Listing17, ImageUrl = "/uploads/listings/jbl_flip6_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(15) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001C"), ListingId = Listing17, ImageUrl = "/uploads/listings/jbl_flip6_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(15) },

            // Listing 18: Electric bike
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001D"), ListingId = Listing18, ImageUrl = "/uploads/listings/nijia_ebike_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T1.AddDays(16) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001E"), ListingId = Listing18, ImageUrl = "/uploads/listings/nijia_ebike_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T1.AddDays(16) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-00000000001F"), ListingId = Listing18, ImageUrl = "/uploads/listings/nijia_ebike_03.jpg", DisplayOrder = 3, IsCover = false, CreatedAt = T1.AddDays(16) },

            // Listing 19: Tripod
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000020"), ListingId = Listing19, ImageUrl = "/uploads/listings/velbon_tripod_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T2 },

            // Listing 20: Medical combo
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000021"), ListingId = Listing20, ImageUrl = "/uploads/listings/medical_combo_01.jpg", DisplayOrder = 1, IsCover = true, CreatedAt = T2.AddDays(1) },
            new() { Id = Guid.Parse("C0000000-0000-0000-0000-000000000022"), ListingId = Listing20, ImageUrl = "/uploads/listings/medical_combo_02.jpg", DisplayOrder = 2, IsCover = false, CreatedAt = T2.AddDays(1) },
        };

        _context.ListingImages.AddRange(images);
    }

    // ============================================================
    // 4. LISTING TAGS - Tag associations for listings
    // ============================================================
    private async Task SeedListingTagsAsync()
    {
        if (await _context.ListingTags.AnyAsync())
            return;

        var listingTags = new[]
        {
            // Listing 01: Casio calculator
            new ListingTag { ListingId = Listing01, TagId = TagCasio },
            new ListingTag { ListingId = Listing01, TagId = TagCalculator },
            // Listing 02: Textbook
            new ListingTag { ListingId = Listing02, TagId = TagTextbook },
            // Listing 03: Microscope
            new ListingTag { ListingId = Listing03, TagId = TagMicroscope },
            // Listing 04: Canon camera
            new ListingTag { ListingId = Listing04, TagId = TagCanon },
            new ListingTag { ListingId = Listing04, TagId = TagCamera },
            // Listing 05: Graduation gown
            new ListingTag { ListingId = Listing05, TagId = TagGown },
            // Listing 06: Badminton - no specific tag, skip or add generic
            // Listing 07: Guitar
            new ListingTag { ListingId = Listing07, TagId = TagGuitar },
            // Listing 09: Laptop
            new ListingTag { ListingId = Listing09, TagId = TagLaptop },
            // Listing 14: TI calculator
            new ListingTag { ListingId = Listing14, TagId = TagTexas },
            new ListingTag { ListingId = Listing14, TagId = TagCalculator },
            // Listing 15: Nikon binoculars
            new ListingTag { ListingId = Listing15, TagId = TagNikon },
            // Listing 16: Chemistry lab
            new ListingTag { ListingId = Listing16, TagId = TagChemistry },
            new ListingTag { ListingId = Listing16, TagId = TagMicroscope },
            // Listing 18: Electric bike
            new ListingTag { ListingId = Listing18, TagId = TagBicycle },
            // Listing 19: Tripod camera
            new ListingTag { ListingId = Listing19, TagId = TagCamera },
        };

        _context.ListingTags.AddRange(listingTags);
    }

    // ============================================================
    // 5. UPVOTES - Users upvoting listings
    // ============================================================
    private async Task SeedUpvotesAsync()
    {
        if (await _context.Upvotes.AnyAsync(u => u.Id == Guid.Parse("D0000000-0000-0000-0000-000000000001")))
            return;

        var upvotes = new[]
        {
            // Listing 01 (Casio) - 12 upvotes from various users
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000001"), ListingId = Listing01, UserId = UserBinh, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000002"), ListingId = Listing01, UserId = UserCuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000003"), ListingId = Listing01, UserId = UserDung, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000004"), ListingId = Listing01, UserId = UserEm, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000005"), ListingId = Listing01, UserId = UserPhuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000006"), ListingId = Listing01, UserId = UserGiang, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000007"), ListingId = Listing01, UserId = UserHuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000008"), ListingId = Listing01, UserId = UserKhanh, CreatedAt = T2 },

            // Listing 04 (Canon M50) - 8 upvotes (popular item)
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000009"), ListingId = Listing04, UserId = UserAn, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000A"), ListingId = Listing04, UserId = UserBinh, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000B"), ListingId = Listing04, UserId = UserDung, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000C"), ListingId = Listing04, UserId = UserEm, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000D"), ListingId = Listing04, UserId = UserPhuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000E"), ListingId = Listing04, UserId = UserHuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000000F"), ListingId = Listing04, UserId = UserKhanh, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000010"), ListingId = Listing04, UserId = UserGiang, CreatedAt = T2 },

            // Listing 07 (Guitar) - 5 upvotes
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000011"), ListingId = Listing07, UserId = UserAn, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000012"), ListingId = Listing07, UserId = UserBinh, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000013"), ListingId = Listing07, UserId = UserCuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000014"), ListingId = Listing07, UserId = UserHuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000015"), ListingId = Listing07, UserId = UserKhanh, CreatedAt = T2 },

            // Listing 09 (Dell Laptop) - 6 upvotes
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000016"), ListingId = Listing09, UserId = UserBinh, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000017"), ListingId = Listing09, UserId = UserCuong, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000018"), ListingId = Listing09, UserId = UserDung, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000019"), ListingId = Listing09, UserId = UserEm, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001A"), ListingId = Listing09, UserId = UserGiang, CreatedAt = T2 },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001B"), ListingId = Listing09, UserId = UserKhanh, CreatedAt = T2 },

            // Listing 11 (Bicycle) - 4 upvotes
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001C"), ListingId = Listing11, UserId = UserAn, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001D"), ListingId = Listing11, UserId = UserBinh, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001E"), ListingId = Listing11, UserId = UserCuong, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-00000000001F"), ListingId = Listing11, UserId = UserHuong, CreatedAt = T2.AddDays(1) },

            // Listing 18 (Electric bike) - 4 upvotes
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000020"), ListingId = Listing18, UserId = UserAn, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000021"), ListingId = Listing18, UserId = UserDung, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000022"), ListingId = Listing18, UserId = UserEm, CreatedAt = T2.AddDays(1) },
            new Upvote { Id = Guid.Parse("D0000000-0000-0000-0000-000000000023"), ListingId = Listing18, UserId = UserGiang, CreatedAt = T2.AddDays(1) },
        };

        _context.Upvotes.AddRange(upvotes);
    }

    // ============================================================
    // 6. COMMENTS - Comments and nested replies on listings
    // ============================================================
    private async Task SeedCommentsAsync()
    {
        if (await _context.Comments.AnyAsync(c => c.Id == Guid.Parse("E0000000-0000-0000-0000-000000000001")))
            return;

        var comments = new[]
        {
            // ── Listing 01 (Casio) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000001"), ListingId = Listing01, UserId = UserBinh, ParentCommentId = null, Content = "Máy còn tốt không bạn? Mình cần mượn để thi cuối kỳ Giải tích.", CreatedAt = T2 },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000002"), ListingId = Listing01, UserId = UserAn, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-000000000001"), Content = "Máy còn mới lắm bạn ơi, mình mới mua đầu năm nay. Pin vẫn zin.", CreatedAt = T2.AddHours(2) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000003"), ListingId = Listing01, UserId = UserKhanh, ParentCommentId = null, Content = "Bạn có cho mượn qua tuần sau không? Mình ở Thủ Đức luôn nè.", CreatedAt = T2.AddDays(1) },

            // ── Listing 04 (Canon M50) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000004"), ListingId = Listing04, UserId = UserDung, ParentCommentId = null, Content = "Máy có lens nào khác không bạn? Mình cần chụp chân dung đồ án.", CreatedAt = T2.AddDays(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000005"), ListingId = Listing04, UserId = UserCuong, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-000000000004"), Content = "Hiện mình chỉ có lens kit thôi bạn. Chụp chân dung vẫn ổn mà.", CreatedAt = T2.AddDays(1).AddHours(3) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000006"), ListingId = Listing04, UserId = UserHuong, ParentCommentId = null, Content = "Bạn cho mình hỏi thuê 3 ngày thì giá có fix không?", CreatedAt = T2.AddDays(2) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000007"), ListingId = Listing04, UserId = UserCuong, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-000000000006"), Content = "Bạn thuê trên 3 ngày mình giảm còn 70k/ngày nha.", CreatedAt = T2.AddDays(2).AddHours(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000008"), ListingId = Listing04, UserId = UserAn, ParentCommentId = null, Content = "Đã book chưa bạn? Mình cũng cần máy chụp đồ án cuối kỳ.", CreatedAt = T3 },

            // ── Listing 07 (Guitar) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000009"), ListingId = Listing07, UserId = UserCuong, ParentCommentId = null, Content = "Đàn có bị lệch cần không bạn? Âm thanh có còn chuẩn không?", CreatedAt = T2.AddDays(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000A"), ListingId = Listing07, UserId = UserPhuong, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-000000000009"), Content = "Cần thẳng, âm thanh chuẩn nhé. Mình mới thay dây cách đây 1 tháng.", CreatedAt = T2.AddDays(1).AddHours(4) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000B"), ListingId = Listing07, UserId = UserKhanh, ParentCommentId = null, Content = "Mình muốn mượn để tập chơi, bạn có thể chỉ mình vài hợp âm cơ bản không?", CreatedAt = T2.AddDays(3) },

            // ── Listing 09 (Dell Laptop) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000C"), ListingId = Listing09, UserId = UserBinh, ParentCommentId = null, Content = "Laptop cài Win mấy vậy bạn? Có chạy được Android Studio không?", CreatedAt = T2.AddDays(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000D"), ListingId = Listing09, UserId = UserAn, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-00000000000C"), Content = "Win 11, Android Studio chạy ngon nhé. Mình để sẵn trong máy luôn.", CreatedAt = T2.AddDays(1).AddHours(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000E"), ListingId = Listing09, UserId = UserGiang, ParentCommentId = null, Content = "Bạn cho thuê 1 tuần được không? Mình cần làm đồ án gấp.", CreatedAt = T2.AddDays(2) },

            // ── Listing 11 (Bicycle) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-00000000000F"), ListingId = Listing11, UserId = UserDung, ParentCommentId = null, Content = "Xe có kèm khóa không bạn?", CreatedAt = T2.AddDays(1) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000010"), ListingId = Listing11, UserId = UserKhanh, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-00000000000F"), Content = "Có khóa dây đi kèm luôn nha bạn. Yên tâm.", CreatedAt = T2.AddDays(1).AddHours(2) },

            // ── Listing 18 (Electric bike) comments ──
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000011"), ListingId = Listing18, UserId = UserGiang, ParentCommentId = null, Content = "Pin sạc đầy đi được bao nhiêu km vậy bạn?", CreatedAt = T2.AddDays(2) },
            new Comment { Id = Guid.Parse("E0000000-0000-0000-0000-000000000012"), ListingId = Listing18, UserId = UserPhuong, ParentCommentId = Guid.Parse("E0000000-0000-0000-0000-000000000011"), Content = "Khoảng 45km một lần sạc bạn nha. Đi học trong tuần thoải mái.", CreatedAt = T2.AddDays(2).AddHours(3) },
        };

        _context.Comments.AddRange(comments);
    }

    // ============================================================
    // 7. RENTAL REQUESTS - 10 requests with various statuses
    // ============================================================
    private async Task SeedRentalRequestsAsync()
    {
        if (await _context.RentalRequests.AnyAsync(r => r.Id == Request01))
            return;

        var requests = new[]
        {
            // Request 01: Binh mượn Casio của An - Completed (đã hoàn tất)
            new RentalRequest
            {
                Id = Request01,
                ListingId = Listing01,
                RequesterId = UserBinh,
                OwnerId = UserAn,
                Status = RequestStatus.Completed,
                StartDate = T3,
                EndDate = T3.AddDays(7),
                Message = "Chào bạn, mình cần mượn máy tính để thi cuối kỳ. Mình hứa giữ gìn cẩn thận.",
                TotalPrice = 0,
                DepositAmount = 200000,
                CreatedAt = T3,
                UpdatedAt = T5,
            },
            // Request 02: Dung thuê Canon M50 của Cường - InProgress (đang thuê)
            new RentalRequest
            {
                Id = Request02,
                ListingId = Listing04,
                RequesterId = UserDung,
                OwnerId = UserCuong,
                Status = RequestStatus.InProgress,
                StartDate = T3.AddDays(1),
                EndDate = T3.AddDays(4),
                Message = "Mình cần thuê máy ảnh 3 ngày để chụp đồ án Kiến trúc. Cảm ơn bạn!",
                TotalPrice = 240000, // 3 days x 80k/day
                DepositAmount = 2000000,
                CreatedAt = T3.AddDays(1),
                UpdatedAt = T3.AddDays(1).AddHours(5),
            },
            // Request 03: Khanh mượn Guitar của Phương - Completed (đã hoàn tất)
            new RentalRequest
            {
                Id = Request03,
                ListingId = Listing07,
                RequesterId = UserKhanh,
                OwnerId = UserPhuong,
                Status = RequestStatus.Completed,
                StartDate = T3.AddDays(2),
                EndDate = T3.AddDays(16),
                Message = "Mình muốn mượn đàn để tập chơi trong 2 tuần. Cảm ơn bạn nhiều!",
                TotalPrice = 0,
                DepositAmount = 500000,
                CreatedAt = T3.AddDays(2),
                UpdatedAt = T5.AddDays(1),
            },
            // Request 04: Giang thuê Laptop Dell của An - InProgress (đang thuê)
            new RentalRequest
            {
                Id = Request04,
                ListingId = Listing09,
                RequesterId = UserGiang,
                OwnerId = UserAn,
                Status = RequestStatus.InProgress,
                StartDate = T3.AddDays(3),
                EndDate = T3.AddDays(10),
                Message = "Chào An, mình cần laptop làm đồ án Web. Cho mình thuê 1 tuần nhé.",
                TotalPrice = 420000, // 7 days x 60k/day
                DepositAmount = 3000000,
                CreatedAt = T3.AddDays(3),
                UpdatedAt = T3.AddDays(3).AddHours(2),
            },
            // Request 05: Huong thuê xe đạp Martin của Khanh - Pending (đang chờ)
            new RentalRequest
            {
                Id = Request05,
                ListingId = Listing11,
                RequesterId = UserHuong,
                OwnerId = UserKhanh,
                Status = RequestStatus.Pending,
                StartDate = T7.AddDays(1),
                EndDate = T7.AddDays(30),
                Message = "Mình muốn thuê xe đạp 1 tháng để đi học. Mình ở Thủ Đức, tiện giao xe luôn.",
                TotalPrice = 450000, // 30 days x 15k/day
                DepositAmount = 1000000,
                CreatedAt = T7,
                UpdatedAt = T7,
            },
            // Request 06: Em mượn ống nhòm của... Em (không thể - self-request)
            // SKIP - self-request not allowed per business rules

            // Request 07: An thuê bảng vẽ Wacom của Hương - Pending
            new RentalRequest
            {
                Id = Request06,
                ListingId = Listing12,
                RequesterId = UserAn,
                OwnerId = UserHuong,
                Status = RequestStatus.Pending,
                StartDate = T7.AddDays(2),
                EndDate = T7.AddDays(9),
                Message = "Mình cần bảng vẽ làm đồ án UI/UX. Cho mình thuê 1 tuần nha.",
                TotalPrice = 175000, // 7 days x 25k/day
                DepositAmount = 800000,
                CreatedAt = T7.AddDays(-1),
                UpdatedAt = T7.AddDays(-1),
            },
            // Request 08: Binh thuê TI-84 của Cường - Accepted (đã chấp nhận, chưa bắt đầu)
            new RentalRequest
            {
                Id = Request07,
                ListingId = Listing14,
                RequesterId = UserBinh,
                OwnerId = UserCuong,
                Status = RequestStatus.Accepted,
                StartDate = T7.AddDays(3),
                EndDate = T7.AddDays(5),
                Message = "Mình cần máy tính đồ thị để thi XSTK. Cho mình thuê 2 ngày nhé!",
                TotalPrice = 30000, // 2 days x 15k/day
                DepositAmount = 500000,
                CreatedAt = T7.AddDays(-2),
                UpdatedAt = T7.AddDays(-1),
            },
            // Request 09: Em thuê xe đạp điện của Phương - Rejected
            new RentalRequest
            {
                Id = Request08,
                ListingId = Listing18,
                RequesterId = UserEm,
                OwnerId = UserPhuong,
                Status = RequestStatus.Rejected,
                StartDate = T4,
                EndDate = T4.AddDays(14),
                Message = "Mình muốn thuê xe đạp điện 2 tuần để đi lâm sàng ở bệnh viện.",
                TotalPrice = 420000, // 14 days x 30k/day
                DepositAmount = 2000000,
                CreatedAt = T4,
                UpdatedAt = T4.AddHours(6),
            },
            // Request 10: Cường thuê áo blouse + ống nghe của Em - Pending
            new RentalRequest
            {
                Id = Request09,
                ListingId = Listing20,
                RequesterId = UserCuong,
                OwnerId = UserEm,
                Status = RequestStatus.Pending,
                StartDate = T7.AddDays(5),
                EndDate = T7.AddDays(19),
                Message = "Mình cần áo blouse và ống nghe cho đợt thực tập lâm sàng 2 tuần.",
                TotalPrice = 280000, // 14 days x 20k/day
                DepositAmount = 500000,
                CreatedAt = T7,
                UpdatedAt = T7,
            },
            // Request 11: Huong thuê xe đạp điện của Phương - Accepted (the one that got Reserved status)
            new RentalRequest
            {
                Id = Request10,
                ListingId = Listing18,
                RequesterId = UserHuong,
                OwnerId = UserPhuong,
                Status = RequestStatus.Accepted,
                StartDate = T7.AddDays(1),
                EndDate = T7.AddDays(15),
                Message = "Mình muốn thuê xe đạp điện để đi làm thêm. Cảm ơn bạn!",
                TotalPrice = 420000, // 14 days x 30k/day
                DepositAmount = 2000000,
                CreatedAt = T3.AddDays(3),
                UpdatedAt = T3.AddDays(3).AddHours(4),
            },
        };

        _context.RentalRequests.AddRange(requests);
    }

    // ============================================================
    // 8. DEPOSITS - Deposit records for rental requests
    // ============================================================
    private async Task SeedDepositsAsync()
    {
        if (await _context.Deposits.AnyAsync(d => d.Id == Guid.Parse("A1000000-0000-0000-0000-000000000001")))
            return;

        var deposits = new[]
        {
            // Deposit for Request 01 (completed - refunded)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000001"),
                RentalRequestId = Request01,
                Amount = 200000,
                Status = DepositStatus.Refunded,
                PaymentProvider = "MoMo",
                ProviderTransactionId = "MOMO-TEST-001",
                PaidAt = T3,
                RefundedAt = T5,
                CreatedAt = T3,
                UpdatedAt = T5,
            },
            // Deposit for Request 02 (in progress - paid)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000002"),
                RentalRequestId = Request02,
                Amount = 2000000,
                Status = DepositStatus.Paid,
                PaymentProvider = "MoMo",
                ProviderTransactionId = "MOMO-TEST-002",
                PaidAt = T3.AddDays(1),
                RefundedAt = null,
                CreatedAt = T3.AddDays(1),
                UpdatedAt = T3.AddDays(1).AddHours(5),
            },
            // Deposit for Request 03 (completed - refunded)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000003"),
                RentalRequestId = Request03,
                Amount = 500000,
                Status = DepositStatus.Refunded,
                PaymentProvider = null, // manual cash deposit
                ProviderTransactionId = null,
                PaidAt = T3.AddDays(2),
                RefundedAt = T5.AddDays(1),
                CreatedAt = T3.AddDays(2),
                UpdatedAt = T5.AddDays(1),
            },
            // Deposit for Request 04 (in progress - paid)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000004"),
                RentalRequestId = Request04,
                Amount = 3000000,
                Status = DepositStatus.Paid,
                PaymentProvider = "MoMo",
                ProviderTransactionId = "MOMO-TEST-004",
                PaidAt = T3.AddDays(3),
                RefundedAt = null,
                CreatedAt = T3.AddDays(3),
                UpdatedAt = T3.AddDays(3).AddHours(2),
            },
            // Deposit for Request 05 (pending request - pending deposit)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000005"),
                RentalRequestId = Request05,
                Amount = 1000000,
                Status = DepositStatus.Pending,
                PaymentProvider = null,
                ProviderTransactionId = null,
                PaidAt = null,
                RefundedAt = null,
                CreatedAt = T7,
                UpdatedAt = T7,
            },
            // Deposit for Request 07 (accepted - pending deposit)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000006"),
                RentalRequestId = Request07,
                Amount = 500000,
                Status = DepositStatus.Pending,
                PaymentProvider = null,
                ProviderTransactionId = null,
                PaidAt = null,
                RefundedAt = null,
                CreatedAt = T7.AddDays(-2),
                UpdatedAt = T7.AddDays(-1),
            },
            // Deposit for Request 08 (rejected - no deposit needed, cancelled)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000007"),
                RentalRequestId = Request08,
                Amount = 2000000,
                Status = DepositStatus.Cancelled,
                PaymentProvider = null,
                ProviderTransactionId = null,
                PaidAt = null,
                RefundedAt = null,
                CreatedAt = T4,
                UpdatedAt = T4.AddHours(6),
            },
            // Deposit for Request 10 (accepted - pending)
            new Deposit
            {
                Id = Guid.Parse("A1000000-0000-0000-0000-000000000008"),
                RentalRequestId = Request10,
                Amount = 2000000,
                Status = DepositStatus.Pending,
                PaymentProvider = null,
                ProviderTransactionId = null,
                PaidAt = null,
                RefundedAt = null,
                CreatedAt = T3.AddDays(3),
                UpdatedAt = T3.AddDays(3).AddHours(4),
            },
        };

        _context.Deposits.AddRange(deposits);
    }

    // ============================================================
    // 9. CONVERSATIONS - 8 chat conversations
    // ============================================================
    private async Task SeedConversationsAsync()
    {
        if (await _context.Conversations.AnyAsync(c => c.Id == Conv01))
            return;

        var conversations = new[]
        {
            // Conv 01: An (owner) and Binh (requester) about Listing 01 (Casio)
            new Conversation
            {
                Id = Conv01,
                ListingId = Listing01,
                RentalRequestId = Request01,
                OwnerId = UserAn,
                RequesterId = UserBinh,
                LastMessageAt = T5,
                CreatedAt = T3,
            },
            // Conv 02: Cuong (owner) and Dung (requester) about Listing 04 (Canon M50)
            new Conversation
            {
                Id = Conv02,
                ListingId = Listing04,
                RentalRequestId = Request02,
                OwnerId = UserCuong,
                RequesterId = UserDung,
                LastMessageAt = T4.AddHours(3),
                CreatedAt = T3.AddDays(1),
            },
            // Conv 03: Phuong (owner) and Khanh (requester) about Listing 07 (Guitar)
            new Conversation
            {
                Id = Conv03,
                ListingId = Listing07,
                RentalRequestId = Request03,
                OwnerId = UserPhuong,
                RequesterId = UserKhanh,
                LastMessageAt = T5.AddDays(1),
                CreatedAt = T3.AddDays(2),
            },
            // Conv 04: An (owner) and Giang (requester) about Listing 09 (Laptop)
            new Conversation
            {
                Id = Conv04,
                ListingId = Listing09,
                RentalRequestId = Request04,
                OwnerId = UserAn,
                RequesterId = UserGiang,
                LastMessageAt = T4.AddDays(1),
                CreatedAt = T3.AddDays(3),
            },
            // Conv 05: Khanh (owner) and Huong (requester) about Listing 11 (Bicycle) - pending
            new Conversation
            {
                Id = Conv05,
                ListingId = Listing11,
                RentalRequestId = Request05,
                OwnerId = UserKhanh,
                RequesterId = UserHuong,
                LastMessageAt = T7,
                CreatedAt = T7,
            },
            // Conv 06: Huong (owner) and An (requester) about Listing 12 (Wacom) - pending
            new Conversation
            {
                Id = Conv06,
                ListingId = Listing12,
                RentalRequestId = Request06,
                OwnerId = UserHuong,
                RequesterId = UserAn,
                LastMessageAt = T7,
                CreatedAt = T7.AddDays(-1),
            },
            // Conv 07: Phuong (owner) and Huong (requester) about Listing 18 (Electric bike) - accepted
            new Conversation
            {
                Id = Conv07,
                ListingId = Listing18,
                RentalRequestId = Request10,
                OwnerId = UserPhuong,
                RequesterId = UserHuong,
                LastMessageAt = T4,
                CreatedAt = T3.AddDays(3),
            },
            // Conv 08: Cường (owner) and Binh (requester) about Listing 14 (TI-84) - accepted
            new Conversation
            {
                Id = Conv08,
                ListingId = Listing14,
                RentalRequestId = Request07,
                OwnerId = UserCuong,
                RequesterId = UserBinh,
                LastMessageAt = T7,
                CreatedAt = T7.AddDays(-2),
            },
        };

        _context.Conversations.AddRange(conversations);
    }

    // ============================================================
    // 10. MESSAGES - Chat messages in conversations
    // ============================================================
    private async Task SeedMessagesAsync()
    {
        if (await _context.Messages.AnyAsync(m => m.Id == Guid.Parse("A3000000-0000-0000-0000-000000000001")))
            return;

        // Helper to create message with proper status
        Message CreateMsg(Guid id, Guid convId, Guid senderId, string content, DateTime time, bool isRead = true) =>
            new()
            {
                Id = id,
                ConversationId = convId,
                SenderId = senderId,
                Content = content,
                Status = isRead ? MessageStatus.Read : MessageStatus.Sent,
                ReadAt = isRead ? time.AddMinutes(5) : null,
                CreatedAt = time,
            };

        var messages = new List<Message>
        {
            // ── Conv 01: An (owner) & Binh about Casio calculator ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000001"), Conv01, UserBinh, "Chào bạn, mình thấy bài đăng máy tính Casio của bạn. Còn không bạn?", T3),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000002"), Conv01, UserAn, "Chào Bình, máy vẫn còn nha. Bạn cần mượn khi nào?", T3.AddMinutes(15)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000003"), Conv01, UserBinh, "Mình cần mượn từ thứ 2 tuần sau, khoảng 1 tuần để thi cuối kỳ.", T3.AddMinutes(30)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000004"), Conv01, UserAn, "Được nha, bạn gửi yêu cầu trên app để mình xác nhận nhé.", T3.AddMinutes(45)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000005"), Conv01, UserBinh, "Mình gửi rồi đó. Cảm ơn bạn nhiều!", T3.AddHours(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000006"), Conv01, UserAn, "OK mình đã accept. Nhớ giữ gìn máy cẩn thận nha!", T3.AddHours(2)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000007"), Conv01, UserBinh, "Mình trả máy xong rồi. Máy vẫn tốt, cảm ơn bạn rất nhiều!", T5),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000008"), Conv01, UserAn, "Cảm ơn Bình đã giữ gìn cẩn thận. Hẹn gặp lại!", T5.AddMinutes(10)),

            // ── Conv 02: Cuong (owner) & Dung about Canon M50 ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000009"), Conv02, UserDung, "Chào Cường, mình muốn thuê máy ảnh Canon của bạn 3 ngày.", T3.AddDays(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000A"), Conv02, UserCuong, "Chào Dung, được bạn ơi. Bạn cần chụp gì vậy?", T3.AddDays(1).AddMinutes(10)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000B"), Conv02, UserDung, "Mình cần chụp mô hình đồ án Kiến trúc. Mình gửi yêu cầu rồi đó.", T3.AddDays(1).AddMinutes(20)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000C"), Conv02, UserCuong, "OK mình accept rồi. Bạn qua lấy máy chiều nay nha. Mình ở Q10.", T3.AddDays(1).AddHours(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000D"), Conv02, UserDung, "Cảm ơn Cường! Chiều nay tầm 3h mình qua.", T3.AddDays(1).AddHours(1).AddMinutes(5)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000E"), Conv02, UserDung, "Cho mình hỏi máy sạc pin đầy chưa bạn?", T4),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000000F"), Conv02, UserCuong, "Mình sạc đầy 2 pin luôn rồi, bạn yên tâm.", T4.AddMinutes(5)),

            // ── Conv 03: Phuong (owner) & Khanh about Guitar ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000010"), Conv03, UserKhanh, "Chào Phương, mình muốn mượn đàn guitar tập chơi. Còn không bạn?", T3.AddDays(2)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000011"), Conv03, UserPhuong, "Dạ còn, bạn mượn bao lâu?", T3.AddDays(2).AddMinutes(20)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000012"), Conv03, UserKhanh, "Khoảng 2 tuần được không bạn?", T3.AddDays(2).AddMinutes(30)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000013"), Conv03, UserPhuong, "Được nha. Bạn gửi request đi mình duyệt.", T3.AddDays(2).AddHours(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000014"), Conv03, UserKhanh, "Mình trả đàn rồi. Cảm ơn Phương nhiều! Đàn hay lắm.", T5.AddDays(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000015"), Conv03, UserPhuong, "Dạ không có gì. Hy vọng bạn tiếp tục tập chơi nha.", T5.AddDays(1).AddMinutes(15)),

            // ── Conv 04: An (owner) & Giang about Dell Laptop ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000016"), Conv04, UserGiang, "Chào An, mình cần thuê laptop làm đồ án Web. Máy còn không?", T3.AddDays(3)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000017"), Conv04, UserAn, "Chào Giang, máy còn nè. Bạn cần cấu hình sao?", T3.AddDays(3).AddMinutes(5)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000018"), Conv04, UserGiang, "Mình cần chạy VS Code, Node.js thôi. Cấu hình máy bạn ok rồi.", T3.AddDays(3).AddMinutes(15)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000019"), Conv04, UserAn, "OK bạn gửi request đi. Mình ở Thủ Đức, bạn qua lấy được không?", T3.AddDays(3).AddHours(1)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001A"), Conv04, UserGiang, "Mình cũng ở Thủ Đức nè, chiều mai mình qua lấy.", T3.AddDays(3).AddHours(2)),

            // ── Conv 05: Khanh (owner) & Huong about Bicycle - pending ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001B"), Conv05, UserHuong, "Chào Khánh, mình muốn thuê xe đạp 1 tháng đi học. Còn xe không?", T7),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001C"), Conv05, UserKhanh, "Chào Hương, xe vẫn còn nha. Bạn gửi yêu cầu đi mình duyệt.", T7.AddMinutes(10)),

            // ── Conv 07: Phuong (owner) & Huong about Electric bike - accepted ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001D"), Conv07, UserHuong, "Chào Phương, mình muốn thuê xe đạp điện.", T3.AddDays(3)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001E"), Conv07, UserPhuong, "Chào Hương, xe còn nè. Bạn thuê bao lâu?", T3.AddDays(3).AddMinutes(10)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-00000000001F"), Conv07, UserHuong, "2 tuần nha. Mình cần đi làm thêm.", T3.AddDays(3).AddMinutes(20)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000020"), Conv07, UserPhuong, "OK mình duyệt rồi. Bạn chuyển cọc qua MoMo nha.", T3.AddDays(3).AddHours(4)),

            // ── Conv 08: Cuong (owner) & Binh about TI-84 - accepted ──
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000021"), Conv08, UserBinh, "Chào Cường, mình cần thuê máy TI-84 để thi.", T7.AddDays(-2)),
            CreateMsg(Guid.Parse("A3000000-0000-0000-0000-000000000022"), Conv08, UserCuong, "OK Bình, mình duyệt rồi. Bạn qua lấy trước ngày thi nha.", T7.AddDays(-1)),
        };

        _context.Messages.AddRange(messages);
    }

    // ============================================================
    // 11. REVIEWS - User reviews after completed transactions
    // ============================================================
    private async Task SeedReviewsAsync()
    {
        if (await _context.Reviews.AnyAsync(r => r.Id == Guid.Parse("A4000000-0000-0000-0000-000000000001")))
            return;

        var reviews = new[]
        {
            // Review 01: Binh đánh giá An (từ Request 01 - Casio, completed)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000001"),
                RentalRequestId = Request01,
                ReviewerId = UserBinh,
                RevieweeId = UserAn,
                Rating = 5,
                Comment = "Bạn An rất tốt bụng, máy còn mới, giao đúng hẹn. Sẽ tiếp tục mượn nếu cần!",
                ReputationDelta = 1.50m,
                CreatedAt = T6,
            },
            // Review 02: An đánh giá Binh (từ Request 01 - Casio, completed)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000002"),
                RentalRequestId = Request01,
                ReviewerId = UserAn,
                RevieweeId = UserBinh,
                Rating = 5,
                Comment = "Bình giữ máy rất cẩn thận, trả đúng hẹn. Rất đáng tin cậy!",
                ReputationDelta = 2.00m,
                CreatedAt = T6.AddHours(1),
            },
            // Review 03: Khanh đánh giá Phương (từ Request 03 - Guitar, completed)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000003"),
                RentalRequestId = Request03,
                ReviewerId = UserKhanh,
                RevieweeId = UserPhuong,
                Rating = 4,
                Comment = "Đàn tốt, Phương nhiệt tình hướng dẫn cách bảo quản. Chỉ tiếc là dây số 3 hơi cũ một chút.",
                ReputationDelta = 0.50m,
                CreatedAt = T6.AddDays(-1),
            },
            // Review 04: Phương đánh giá Khanh (từ Request 03 - Guitar, completed)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000004"),
                RentalRequestId = Request03,
                ReviewerId = UserPhuong,
                RevieweeId = UserKhanh,
                Rating = 4,
                Comment = "Khanh trả đàn đúng hẹn, giữ gìn cẩn thận. Lần sau nhớ trả sớm hơn 1 ngày thì tốt hơn.",
                ReputationDelta = 0.00m,
                CreatedAt = T6.AddDays(-1).AddHours(2),
            },
            // Review 05: Cường được đánh giá bởi Dung (đánh giá từ giao dịch trước đó - mock)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000005"),
                RentalRequestId = Request02, // Note: this transaction is InProgress, but in real scenario this might be from a previous completed one
                ReviewerId = UserDung,
                RevieweeId = UserCuong,
                Rating = 5,
                Comment = "Review từ lần thuê trước: Cường rất uy tín, thiết bị tốt! Lần này thuê tiếp.",
                ReputationDelta = 2.00m,
                CreatedAt = T6.AddDays(-3),
            },
            // Review 06: Cường đánh giá Dung (từ Request02 - cùng giao dịch Canon M50)
            new Review
            {
                Id = Guid.Parse("A4000000-0000-0000-0000-000000000006"),
                RentalRequestId = Request02,
                ReviewerId = UserCuong,
                RevieweeId = UserDung,
                Rating = 5,
                Comment = "Dung thuê máy rất có trách nhiệm, giữ gìn cẩn thận, trả đúng hẹn. Rất hài lòng!",
                ReputationDelta = 2.00m,
                CreatedAt = T6.AddDays(-5),
            },
        };

        _context.Reviews.AddRange(reviews);
    }

    // ============================================================
    // 12. NOTIFICATIONS - Various notification types
    // ============================================================
    private async Task SeedNotificationsAsync()
    {
        if (await _context.Notifications.AnyAsync(n => n.Id == Guid.Parse("A5000000-0000-0000-0000-000000000001")))
            return;

        var notifications = new[]
        {
            // ── Notifications for An (owner of Listing 01 Casio & Listing 09 Laptop) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000001"),
                UserId = UserAn,
                Type = NotificationType.Upvote,
                Title = "Bài đăng của bạn được upvote",
                Body = "Trần Thị Bình đã upvote bài đăng 'Máy tính Casio fx-570VN PLUS' của bạn.",
                ReferenceId = Listing01,
                ReferenceType = "Listing",
                IsRead = true,
                ReadAt = T2.AddHours(1),
                CreatedAt = T2,
            },
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000002"),
                UserId = UserAn,
                Type = NotificationType.Comment,
                Title = "Bình luận mới trên bài đăng của bạn",
                Body = "Trần Thị Bình đã bình luận: 'Máy còn tốt không bạn? Mình cần mượn để thi cuối kỳ Giải tích.'",
                ReferenceId = Listing01,
                ReferenceType = "Listing",
                IsRead = true,
                ReadAt = T2.AddHours(2),
                CreatedAt = T2,
            },
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000003"),
                UserId = UserAn,
                Type = NotificationType.RentalRequest,
                Title = "Yêu cầu mượn đồ mới",
                Body = "Trần Thị Bình muốn mượn 'Máy tính Casio fx-570VN PLUS' của bạn.",
                ReferenceId = Request01,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T3.AddHours(1),
                CreatedAt = T3,
            },
            // Unread notification for An
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000004"),
                UserId = UserAn,
                Type = NotificationType.Message,
                Title = "Tin nhắn mới từ Đặng Văn Giang",
                Body = "Mình cũng ở Thủ Đức nè, chiều mai mình qua lấy.",
                ReferenceId = Conv04,
                ReferenceType = "Conversation",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T3.AddDays(3).AddHours(2),
            },

            // ── Notifications for Cường (owner of Listing 04 Canon M50) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000005"),
                UserId = UserCuong,
                Type = NotificationType.Upvote,
                Title = "Bài đăng của bạn được upvote",
                Body = "Nguyễn Văn An đã upvote bài đăng 'Máy ảnh Canon EOS M50' của bạn.",
                ReferenceId = Listing04,
                ReferenceType = "Listing",
                IsRead = true,
                ReadAt = T2.AddHours(1),
                CreatedAt = T2,
            },
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000006"),
                UserId = UserCuong,
                Type = NotificationType.RentalRequest,
                Title = "Yêu cầu thuê đồ mới",
                Body = "Phạm Thị Dung muốn thuê 'Máy ảnh Canon EOS M50' của bạn.",
                ReferenceId = Request02,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T3.AddDays(1).AddHours(1),
                CreatedAt = T3.AddDays(1),
            },
            // Unread notification for Cường
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000007"),
                UserId = UserCuong,
                Type = NotificationType.Review,
                Title = "Bạn nhận được đánh giá mới",
                Body = "Phạm Thị Dung đã đánh giá bạn 5 sao: 'Cường rất uy tín, thiết bị tốt!'",
                ReferenceId = Guid.Parse("A4000000-0000-0000-0000-000000000005"),
                ReferenceType = "Review",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T6.AddDays(-3),
            },

            // ── Notifications for Phương (owner of Listing 07 Guitar & Listing 18 Electric bike) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000008"),
                UserId = UserPhuong,
                Type = NotificationType.RentalRequest,
                Title = "Yêu cầu mượn đồ mới",
                Body = "Ngô Văn Khánh muốn mượn 'Đàn guitar acoustic Yamaha F310' của bạn.",
                ReferenceId = Request03,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T3.AddDays(2).AddHours(1),
                CreatedAt = T3.AddDays(2),
            },
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000009"),
                UserId = UserPhuong,
                Type = NotificationType.RequestStatus,
                Title = "Yêu cầu thuê đã bị từ chối (tự động)",
                Body = "Yêu cầu thuê 'Xe đạp điện Nijia' của Hoàng Văn Em đã bị từ chối do bạn đã chấp nhận yêu cầu khác.",
                ReferenceId = Request08,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T4.AddHours(7),
                CreatedAt = T4.AddHours(6),
            },
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000A"),
                UserId = UserPhuong,
                Type = NotificationType.Review,
                Title = "Bạn nhận được đánh giá mới",
                Body = "Ngô Văn Khánh đã đánh giá bạn 4 sao.",
                ReferenceId = Guid.Parse("A4000000-0000-0000-0000-000000000003"),
                ReferenceType = "Review",
                IsRead = true,
                ReadAt = T6.AddDays(-1).AddHours(1),
                CreatedAt = T6.AddDays(-1),
            },

            // ── Notifications for Khanh (requester) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000B"),
                UserId = UserKhanh,
                Type = NotificationType.RequestStatus,
                Title = "Yêu cầu mượn đồ đã được chấp nhận",
                Body = "Vũ Thị Phương đã chấp nhận yêu cầu mượn 'Đàn guitar acoustic Yamaha F310' của bạn.",
                ReferenceId = Request03,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T3.AddDays(2).AddHours(2),
                CreatedAt = T3.AddDays(2).AddHours(1),
            },
            // Unread notification for Khanh
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000C"),
                UserId = UserKhanh,
                Type = NotificationType.Message,
                Title = "Tin nhắn mới từ Bùi Thị Hương",
                Body = "Chào Khánh, mình muốn thuê xe đạp 1 tháng đi học.",
                ReferenceId = Conv05,
                ReferenceType = "Conversation",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T7,
            },

            // ── Notifications for Binh (requester) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000D"),
                UserId = UserBinh,
                Type = NotificationType.RequestStatus,
                Title = "Yêu cầu thuê đồ đã được chấp nhận",
                Body = "Lê Văn Cường đã chấp nhận yêu cầu thuê 'Máy tính TI-84 Plus CE' của bạn.",
                ReferenceId = Request07,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T7.AddDays(-1).AddHours(1),
                CreatedAt = T7.AddDays(-1),
            },

            // ── Notifications for Dung (requester) ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000E"),
                UserId = UserDung,
                Type = NotificationType.RequestStatus,
                Title = "Yêu cầu thuê đồ đã được chấp nhận",
                Body = "Lê Văn Cường đã chấp nhận yêu cầu thuê 'Máy ảnh Canon EOS M50' của bạn.",
                ReferenceId = Request02,
                ReferenceType = "RentalRequest",
                IsRead = true,
                ReadAt = T3.AddDays(1).AddHours(6),
                CreatedAt = T3.AddDays(1).AddHours(5),
            },

            // ── Unread notification for Hương ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-00000000000F"),
                UserId = UserHuong,
                Type = NotificationType.RequestStatus,
                Title = "Yêu cầu thuê đồ đã được chấp nhận",
                Body = "Vũ Thị Phương đã chấp nhận yêu cầu thuê 'Xe đạp điện Nijia' của bạn.",
                ReferenceId = Request10,
                ReferenceType = "RentalRequest",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T3.AddDays(3).AddHours(4),
            },
            // Unread notification for Hương
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000010"),
                UserId = UserHuong,
                Type = NotificationType.Upvote,
                Title = "Bài đăng của bạn được upvote",
                Body = "Nguyễn Văn An đã upvote bài đăng 'Bảng vẽ điện tử Wacom Intuos' của bạn.",
                ReferenceId = Listing12,
                ReferenceType = "Listing",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T7,
            },

            // ── Notifications for Em ──
            new Notification
            {
                Id = Guid.Parse("A5000000-0000-0000-0000-000000000011"),
                UserId = UserEm,
                Type = NotificationType.RentalRequest,
                Title = "Yêu cầu thuê đồ mới",
                Body = "Lê Văn Cường muốn thuê 'Combo áo blouse + ống nghe' của bạn.",
                ReferenceId = Request09,
                ReferenceType = "RentalRequest",
                IsRead = false,
                ReadAt = null,
                CreatedAt = T7,
            },
        };

        _context.Notifications.AddRange(notifications);
    }
}
