import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../features/listings/models/listing_summary_dto.dart';
import '../utils/image_url_resolver.dart';
import 'user_avatar.dart';

/// Card widget displaying a listing summary.
class ListingCard extends StatelessWidget {
  final ListingSummaryDto listing;
  final VoidCallback? onTap;
  final String mediaBaseUrl;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    required this.mediaBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = listing.listingType.name == 'borrow'
        ? 'Miễn phí'
        : '${listing.pricePerDay.toStringAsFixed(0)}đ/ngày';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (listing.coverImageUrl != null)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: resolveImageUrl(mediaBaseUrl, listing.coverImageUrl),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.neutral100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.neutral100,
                    child: const Icon(Icons.image_not_supported,
                        color: AppColors.neutral500),
                  ),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                color: AppColors.neutral100,
                child: const Center(
                  child:
                      Icon(Icons.image, size: 48, color: AppColors.neutral500),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    priceText,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Meta row
                  Row(
                    children: [
                      if (listing.areaName != null) ...[
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            listing.areaName!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (listing.schoolName != null) ...[
                        const Icon(Icons.school,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            listing.schoolName!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Owner & stats row
                  Row(
                    children: [
                      if (listing.owner != null) ...[
                        UserAvatar(
                          avatarUrl: listing.owner!.avatarUrl,
                          fullName: listing.owner!.fullName,
                          reputationScore: listing.owner!.reputationScore,
                          size: 28,
                          mediaBaseUrl: mediaBaseUrl,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.owner!.fullName,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Upvote count
                      const Icon(Icons.arrow_upward,
                          size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 2),
                      Text(
                        '${listing.upvoteCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      // Comment count
                      const Icon(Icons.chat_bubble_outline,
                          size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 2),
                      Text(
                        '${listing.commentCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
