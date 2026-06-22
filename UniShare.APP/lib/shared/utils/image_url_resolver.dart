/// Resolves server-relative image URLs to absolute URLs.
///
/// The backend stores image URLs as server-relative paths (e.g.
/// `/uploads/listings/abc-123/photo.jpg`). [CachedNetworkImage] and other
/// network image widgets need absolute URLs with scheme and host.
///
/// [mediaBaseUrl] is the server origin (scheme + host + port), e.g.
/// `http://localhost:5056` or `https://staging-api.unishare.com`.
///
/// If [imageUrl] is null, empty, or already absolute (starts with `http://`
/// or `https://`), it is returned as-is.
String resolveImageUrl(String mediaBaseUrl, String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl; // Already absolute
  }
  // Prepend server origin to relative paths like /uploads/...
  return '$mediaBaseUrl$imageUrl';
}
