import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_textfield.dart';
import '../../shared/widgets/place_card.dart';
import 'find_places_controller.dart';

class FindPlacesView extends GetView<FindPlacesController> {
  const FindPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        text: "Find Places",
        leadingIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: CustomTextField(
              hintText: "Search parks, clinics, malls...",
              preffixIcon: Icon(Icons.search, color: AppColors.grey500),
              controller: controller.searchController,
              textcolor: AppColors.textPrimary,
              hasPreffix: true,
              backcolor: AppColors.grey100,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildFilterButton(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.w),
            child: Obx(() => Row(
                  children: [
                    CText(
                      text: "${controller.filteredPlaces.length} places nearby",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kpurple,
                    ),
                  ],
                )),
          ),
          SizedBox(height: 16.h),

       
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredPlaces.isEmpty) {
                return Center(
                  child: CText(
                    text: "No places found.",
                    color: AppColors.textSecondary, fontSize: 14.sp,
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: controller.filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = controller.filteredPlaces[index];
                  return PlaceCard(
                    title: place.name,
                    address: place.address ?? place.description,
                    rating: place.overallRating,
                    imagePath: place.images.isNotEmpty ? place.images.first : "",
                    staffFriendly: place.staffFriendly,
                    quietAvailable: place.quietAvailable,
                    sensoryRatings: place.sensoryRatings,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list, color: AppColors.grey500, size: 20),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.categories.map((cat) {
                  return Obx(() => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: controller.selectedCategory.value == cat,
                          onSelected: (selected) {
                            if (selected) controller.selectCategory(cat);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: controller.selectedCategory.value == cat
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ));
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
