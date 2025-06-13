import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final Color color;
  final double size;
  final bool showDebugLogs;

  const ProfileImage({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.color,
    this.size = 50,
    this.showDebugLogs = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug print to see what image URL we're receiving
    if (showDebugLogs) {
      print('ProfileImage: Attempting to load image from URL: $imageUrl');
    }
    
    // Process the image URL to ensure it's valid
    String? processedImageUrl = imageUrl;
    if (processedImageUrl != null && processedImageUrl.isNotEmpty) {
      // Check if URL is valid and fix common issues
      try {
        // Handle Supabase URLs specifically
        if (processedImageUrl.contains('supabase.co')) {
          // URL is already a Supabase URL, ensure it has https:// prefix
          if (!processedImageUrl.startsWith('http')) {
            processedImageUrl = 'https://$processedImageUrl';
            if (showDebugLogs) {
              print('ProfileImage: Added https:// prefix: $processedImageUrl');
            }
          }
          
          // Check if URL contains storage endpoint
          if (!processedImageUrl.contains('/storage/v1/object/public/')) {
            // This might not be a complete storage URL, log it but don't modify
            if (showDebugLogs) {
              print('ProfileImage: URL might not be a complete Supabase storage URL: $processedImageUrl');
            }
          }
        }
        
        // Validate the URL
        final uri = Uri.parse(processedImageUrl);
        if (!uri.hasScheme) {
          if (showDebugLogs) {
            print('ProfileImage: URL missing scheme, adding https://: $processedImageUrl');
          }
          processedImageUrl = 'https://$processedImageUrl';
        }
        
        if (showDebugLogs) {
          print('ProfileImage: Final processed URL: $processedImageUrl');
        }
      } catch (e) {
        if (showDebugLogs) {
          print('ProfileImage: Error parsing URL: $e');
        }
        processedImageUrl = null;
      }
    } else {
      if (showDebugLogs) {
        print('ProfileImage: No valid image URL provided');
      }
    }
    
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.r / 2),
        child: processedImageUrl != null && processedImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: processedImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2.0,
                  ),
                ),
                errorWidget: (context, url, error) {
                  if (showDebugLogs) {
                    print('ProfileImage: Error loading image: $error, URL: $url');
                  }
                  return _buildNameInitial();
                },
                // Add key caching parameters to avoid stale images
                cacheKey: '$processedImageUrl-${DateTime.now().day}',
                maxHeightDiskCache: 300,
                maxWidthDiskCache: 300,
              )
            : _buildNameInitial(),
      ),
    );
  }

  Widget _buildNameInitial() {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: (size * 0.4).sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
