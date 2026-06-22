import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../utils/image_url_resolver.dart';

/// User avatar with optional reputation badge.
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final double? reputationScore;
  final double size;
  final VoidCallback? onTap;
  final String mediaBaseUrl;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.fullName,
    this.reputationScore,
    this.size = 40,
    this.onTap,
    required this.mediaBaseUrl,
  });

  String get _initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = avatarUrl != null && avatarUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: resolveImageUrl(mediaBaseUrl, avatarUrl),
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: size / 2,
              backgroundImage: imageProvider,
            ),
            errorWidget: (_, __, ___) => _initialsAvatar(),
          )
        : _initialsAvatar();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (reputationScore != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                child: Text(
                  reputationScore!.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.greenLight,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.greenDark,
          fontSize: size / 2.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
