using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace UniShare.API.Migrations
{
    /// <inheritdoc />
    public partial class RemoveHanoiData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Areas",
                keyColumn: "Id",
                keyValue: new Guid("20000000-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000001"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000002"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000003"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000004"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000005"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000006"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000007"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000008"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000009"));

            migrationBuilder.DeleteData(
                table: "Schools",
                keyColumn: "Id",
                keyValue: new Guid("10000000-0000-0000-0000-000000000010"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Areas",
                columns: new[] { "Id", "City", "CreatedAt", "Description", "IsActive", "Name" },
                values: new object[,]
                {
                    { new Guid("20000000-0000-0000-0000-000000000001"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu ký túc xá sinh viên Mỹ Đình", true, "Ký túc xá Mỹ Đình" },
                    { new Guid("20000000-0000-0000-0000-000000000002"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Cầu Giấy", true, "Cầu Giấy" },
                    { new Guid("20000000-0000-0000-0000-000000000003"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Đống Đa", true, "Đống Đa" },
                    { new Guid("20000000-0000-0000-0000-000000000004"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Hai Bà Trưng", true, "Hai Bà Trưng" },
                    { new Guid("20000000-0000-0000-0000-000000000005"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Thanh Xuân", true, "Thanh Xuân" },
                    { new Guid("20000000-0000-0000-0000-000000000006"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực trung tâm Hoàn Kiếm", true, "Hoàn Kiếm" },
                    { new Guid("20000000-0000-0000-0000-000000000007"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Bắc Từ Liêm và Nam Từ Liêm", true, "Từ Liêm" },
                    { new Guid("20000000-0000-0000-0000-000000000008"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Khu vực Hà Đông", true, "Hà Đông" }
                });

            migrationBuilder.InsertData(
                table: "Schools",
                columns: new[] { "Id", "City", "CreatedAt", "IsActive", "Name", "ShortName" },
                values: new object[,]
                {
                    { new Guid("10000000-0000-0000-0000-000000000001"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Bách Khoa Hà Nội", "HUST" },
                    { new Guid("10000000-0000-0000-0000-000000000002"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Quốc Gia Hà Nội", "VNU" },
                    { new Guid("10000000-0000-0000-0000-000000000003"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Kinh Tế Quốc Dân", "NEU" },
                    { new Guid("10000000-0000-0000-0000-000000000004"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Xây Dựng", "NUCE" },
                    { new Guid("10000000-0000-0000-0000-000000000005"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Học viện Công nghệ Bưu chính Viễn thông", "PTIT" },
                    { new Guid("10000000-0000-0000-0000-000000000006"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Thương Mại", "TMU" },
                    { new Guid("10000000-0000-0000-0000-000000000007"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Sư Phạm Hà Nội", "HNUE" },
                    { new Guid("10000000-0000-0000-0000-000000000008"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Ngoại Thương", "FTU" },
                    { new Guid("10000000-0000-0000-0000-000000000009"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Luật Hà Nội", "HLU" },
                    { new Guid("10000000-0000-0000-0000-000000000010"), "Hà Nội", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Đại học Công Nghiệp Hà Nội", "HAUI" }
                });
        }
    }
}
