# ============================================================
# UniShare.API — Multi-stage Docker build for .NET 8
# ============================================================

# ---- Stage 1: Build ----
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore packages (layer caching)
COPY UniShare.API.csproj ./
RUN dotnet restore UniShare.API.csproj

# Copy remaining source and publish
COPY . ./
RUN dotnet publish UniShare.API.csproj -c Release -o /app/publish --no-restore

# ---- Stage 2: Runtime ----
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Expose the HTTP port (ngrok terminates TLS externally)
EXPOSE 5056

COPY --from=build /app/publish ./

ENTRYPOINT ["dotnet", "UniShare.API.dll"]
