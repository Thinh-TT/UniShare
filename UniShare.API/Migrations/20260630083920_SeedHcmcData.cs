using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace UniShare.API.Migrations
{
    /// <inheritdoc />
    public partial class SeedHcmcData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Areas",
                columns: new[] { "Id", "City", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { new Guid("20000000-0000-0000-0000-000000000009"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực trung tâm Quận 1", true, "Quận 1" },
                    { new Guid("20000000-0000-0000-0000-00000000000a"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Quận 3", true, "Quận 3" },
                    { new Guid("20000000-0000-0000-0000-00000000000b"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Quận 5 (gần Đại học Sư phạm, Đại học Y Dược)", true, "Quận 5" },
                    { new Guid("20000000-0000-0000-0000-00000000000c"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Quận 10 (gần Đại học Bách Khoa)", true, "Quận 10" },
                    { new Guid("20000000-0000-0000-0000-00000000000d"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Thủ Đức (khu vực ĐHQG TP.HCM)", true, "Quận Thủ Đức" },
                    { new Guid("20000000-0000-0000-0000-00000000000e"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Bình Thạnh (gần Đại học Ngoại thương, Đại học Văn Lang)", true, "Bình Thạnh" },
                    { new Guid("20000000-0000-0000-0000-00000000000f"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Tân Bình", true, "Tân Bình" },
                    { new Guid("20000000-0000-0000-0000-000000000010"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Gò Vấp", true, "Gò Vấp" },
                    { new Guid("20000000-0000-0000-0000-000000000011"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Quận 7", true, "Quận 7" },
                    { new Guid("20000000-0000-0000-0000-000000000012"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Phú Nhuận", true, "Phú Nhuận" },
                    { new Guid("20000000-0000-0000-0000-000000000013"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Nhà Bè (gần KTX ĐHQG TP.HCM)", true, "Nhà Bè" },
                    { new Guid("20000000-0000-0000-0000-000000000014"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Hóc Môn", true, "Hóc Môn" }
                });

            migrationBuilder.InsertData(
                table: "Schools",
                columns: new[] { "Id", "City", "CreatedAt", "IsActive", "Name", "ShortName" },
                values: new object[,]
                {
                    { new Guid("10000000-0000-0000-0000-000000000011"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Bách Khoa TP.HCM", "HCMUT" },
                    { new Guid("10000000-0000-0000-0000-000000000012"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Khoa học Tự nhiên TP.HCM", "HCMUS" },
                    { new Guid("10000000-0000-0000-0000-000000000013"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Kinh tế TP.HCM", "UEH" },
                    { new Guid("10000000-0000-0000-0000-000000000014"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Sư phạm TP.HCM", "HCMUE" },
                    { new Guid("10000000-0000-0000-0000-000000000015"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Nông Lâm TP.HCM", "NLU" },
                    { new Guid("10000000-0000-0000-0000-000000000016"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Công nghệ Thông tin", "UIT" },
                    { new Guid("10000000-0000-0000-0000-000000000017"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Y Dược TP.HCM", "UMP" },
                    { new Guid("10000000-0000-0000-0000-000000000018"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Kiến Trúc TP.HCM", "UAH" },
                    { new Guid("10000000-0000-0000-0000-000000000019"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Công nghiệp TP.HCM", "IUH" },
                    { new Guid("10000000-0000-0000-0000-000000000020"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Mở TP.HCM", "OU" },
                    { new Guid("10000000-0000-0000-0000-000000000021"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Sài Gòn", "SGU" },
                    { new Guid("10000000-0000-0000-0000-000000000022"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Văn Lang", "VLU" },
                    { new Guid("10000000-0000-0000-0000-000000000023"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Tài chính - Marketing", "UFM" },
                    { new Guid("10000000-0000-0000-0000-000000000024"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Nguyễn Tất Thành", "NTTU" },
                    { new Guid("10000000-0000-0000-0000-000000000025"), "TP. Hồ Chí Minh", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Hoa Sen", "HSU" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000a"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000b"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000c"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000d"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000e"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-00000000000f"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000010"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000013"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000014"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000011"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000012"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000013"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000014"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000015"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000016"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000017"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000018"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000019"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000020"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000021"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000022"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000023"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000024"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000025"));
        }
    }
}
