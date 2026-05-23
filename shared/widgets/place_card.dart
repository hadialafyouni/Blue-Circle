import 'package:bluecircle/shared/widgets/c_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';

class PlaceCard extends StatefulWidget {
  final String title;
  final String address;
  final double rating;
  final String imagePath;
  final bool isOpen;
  final bool staffFriendly;
  final bool quietAvailable;
  final Map<String, double> sensoryRatings;

  const PlaceCard({
    super.key,
    required this.title,
    required this.address,
    required this.rating,
    required this.imagePath,
    this.isOpen = true,
    this.staffFriendly = false,
    this.quietAvailable = false,
    this.sensoryRatings = const {},
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool isFavorite = false;

  void _launchMaps() async {
    final query = Uri.encodeComponent("${widget.title}, ${widget.address}");
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.image_outlined, color: AppColors.grey400),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CText(
                          text: widget.title,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4.w),
                            CText(
                              text: widget.rating.toString(),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : AppColors.grey400,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: _launchMaps,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CText(
                              text: widget.address,
                              fontSize: 12,
                              color: AppColors.primary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (widget.sensoryRatings.containsKey('noise')) _buildTag("Noise: ${widget.sensoryRatings['noise']?.toInt()}/5", Colors.green),
              if (widget.sensoryRatings.containsKey('crowd')) _buildTag("Crowd: ${widget.sensoryRatings['crowd']?.toInt()}/5", Colors.blue),
              if (widget.sensoryRatings.containsKey('light')) _buildTag("Light: ${widget.sensoryRatings['light']?.toInt()}/5", AppColors.kpurple),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (widget.staffFriendly) _buildStatusItem(Icons.check_circle, "Staff Friend", Colors.green),
              if (widget.staffFriendly && widget.quietAvailable) SizedBox(width: 12.w),
              if (widget.quietAvailable) _buildStatusItem(Icons.check_circle, "Quiet", Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: CText(
        text: text,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4.w),
        CText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ],
    );
  }
}
