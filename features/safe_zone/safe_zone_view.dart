import 'package:bluecircle/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_buttons.dart';
import 'safe_zone_controller.dart';

class SafeZoneView extends GetView<SafeZoneController> {
  const SafeZoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'Set Safe Zone'),
      body: Stack(
        children: [


          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.center.value,
                  zoom: 15,
                ),
                onMapCreated: controller.onMapCreated,
                circles: controller.circles.toSet(),
                markers: controller.markers.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              )),


          Positioned(
            right: 20,
            bottom: 180,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 3,
              onPressed: controller.getCurrentLocation,
              child: Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),

       
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.35,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r),
                    topRight: Radius.circular(32.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Container(
                          width: 80.w,
                          height: 5.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),

            
                      CText(
                        text: "Set range",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),

                      SizedBox(height: 20.h),

                   
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CText(
                            text: "Min: 10km",
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          Obx(() => CText(
                                text:
                                    "Max: ${controller.radius.value.toInt()}km",
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              )),
                        ],
                      ),

                      SizedBox(height: 10.h),

                 
                      Obx(() => Slider(
                            value: controller.radius.value,
                            min: 100,
                            max: 2000,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.grey200,
                            onChanged: controller.updateRadius,
                          )),

                      SizedBox(height: 20.h),

                      PrimaryButton(
                        width: double.infinity,
                        text: "Confirm",
                        onTap: controller.confirmSafeZone,
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
          

          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
