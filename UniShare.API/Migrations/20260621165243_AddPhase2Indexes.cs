using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UniShare.API.Migrations
{
    /// <inheritdoc />
    public partial class AddPhase2Indexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Reviews_RentalRequestId_ReviewerId",
                table: "Reviews",
                columns: new[] { "RentalRequestId", "ReviewerId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RentalRequests_ListingId_RequesterId_Status",
                table: "RentalRequests",
                columns: new[] { "ListingId", "RequesterId", "Status" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Reviews_RentalRequestId_ReviewerId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_RentalRequests_ListingId_RequesterId_Status",
                table: "RentalRequests");
        }
    }
}
