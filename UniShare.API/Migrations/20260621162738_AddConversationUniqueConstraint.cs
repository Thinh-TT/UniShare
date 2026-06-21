using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UniShare.API.Migrations
{
    /// <inheritdoc />
    public partial class AddConversationUniqueConstraint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Conversations_ListingId_OwnerId_RequesterId",
                table: "Conversations",
                columns: new[] { "ListingId", "OwnerId", "RequesterId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Conversations_ListingId_OwnerId_RequesterId",
                table: "Conversations");
        }
    }
}
