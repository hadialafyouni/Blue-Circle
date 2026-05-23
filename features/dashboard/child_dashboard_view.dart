import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/role_auth_service.dart';
import '../../shared/widgets/custom_app_bar.dart';
import 'child_dashboard_controller.dart';

class ChildDashboardView extends GetView<ChildDashboardController> {
  const ChildDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isParentFlow = controller.isParentViewer.value;
      final childName = controller.childName;

      return Scaffold(
        appBar: CustomAppBar(
          text: "$childName's Location",
          leadingIcon: isParentFlow,
          actions: [
            if (!isParentFlow)
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await Get.find<RoleAuthService>().signOut();
                },
              ),
          ],
        ),
        body: _buildBody(isParentFlow),
      );
    });
  }

  Widget _buildBody(bool isParentFlow) {
    if (controller.isLoading.value && controller.currentChild.value == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            const Text('Loading child location...'),
          ],
        ),
      );
    }

    if (controller.currentChild.value == null) {
      return const Center(child: Text('Unable to load child profile.'));
    }

    final mapTarget = controller.mapTarget;
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: controller.onMapCreated,
          initialCameraPosition: CameraPosition(target: mapTarget, zoom: 15),
          markers: controller.markers.toSet(),
          circles: controller.circles.toSet(),
          mapType: controller.mapType.value,
          myLocationEnabled: !isParentFlow || controller.isShowingUserFallback,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        if (controller.liveLocation.value != null)
          Positioned(top: 16.h, left: 16.w, child: const _LiveUpdatingBadge()),
        Positioned(
          top: 16.h,
          right: 16.w,
          child: _MapControls(controller: controller),
        ),
        Positioned(
          bottom: 24.h,
          left: 24.w,
          right: 24.w,
          child: _LiveLocationPanel(controller: controller),
        ),
      ],
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({required this.controller});

  final ChildDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlButton(
            tooltip: 'Recenter',
            icon: Icons.my_location,
            onTap: controller.centerOnChild,
          ),
          _MapControlDivider(),
          _MapControlButton(
            tooltip: 'Zoom in',
            icon: Icons.add,
            onTap: controller.zoomIn,
          ),
          _MapControlDivider(),
          _MapControlButton(
            tooltip: 'Zoom out',
            icon: Icons.remove,
            onTap: controller.zoomOut,
          ),
          _MapControlDivider(),
          _MapControlButton(
            tooltip: 'Map style',
            icon: Icons.layers_outlined,
            onTap: controller.cycleMapType,
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 44.w,
        height: 44.w,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(icon, color: AppColors.primary, size: 22.w),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _MapControlDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.w,
      child: Divider(height: 1, thickness: 1, color: AppColors.grey200),
    );
  }
}

class _LiveUpdatingBadge extends StatefulWidget {
  const _LiveUpdatingBadge();

  @override
  State<_LiveUpdatingBadge> createState() => _LiveUpdatingBadgeState();
}

class _LiveUpdatingBadgeState extends State<_LiveUpdatingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28.w,
              height: 28.w,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final value = _controller.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.7 + (value * 0.7),
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(
                              alpha: (1 - value) * 0.22,
                            ),
                          ),
                        ),
                      ),
                      child!,
                    ],
                  );
                },
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Live updating',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveLocationPanel extends StatelessWidget {
  const _LiveLocationPanel({required this.controller});

  final ChildDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final safeZoneStatusText = controller.safeZoneStatusText;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 24.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.locationTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      controller.locationSubtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (safeZoneStatusText.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 18.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      safeZoneStatusText,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (controller.trackingError.value.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              controller.trackingError.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}
