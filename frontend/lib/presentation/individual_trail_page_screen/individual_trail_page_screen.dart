import 'package:trailquest_proto/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart';

class IndividualTrailPageScreen extends StatelessWidget {
  const IndividualTrailPageScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SizedBox(
          height: 694.v,
          width: double.maxFinite,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgImage2400x360,
                width: 360.h,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 65.v),
              ),
              _buildTrailInfoWith(context),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: 68.v,
                  width: 239.h,
                  padding: EdgeInsets.symmetric(vertical: 14.v),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      CustomImageView(
                        imagePath: ImageConstant.imgArrowDownBlack900,
                        height: 20.v,
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(
                          left: 15.h,
                          top: 8.v,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Trail name",
                          style: theme.textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildSaveTrail(context),
      ),
    );
  }

  /// Section Widget
  Widget _buildTrailInfoWith(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          right: 3.h,
          bottom: 7.v,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 27.h,
          vertical: 21.v,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.h),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgSettingsBlack90001,
                    width: 18.h,
                    margin: EdgeInsets.only(bottom: 2.v),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 38.h),
                    child: Text(
                      "XX km ",
                      style: CustomTextStyles.headlineSmallBlack90001,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.v),
            Padding(
              padding: EdgeInsets.only(left: 12.h),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgClock,
                    height: 25.adaptSize,
                    width: 25.adaptSize,
                    margin: EdgeInsets.only(bottom: 1.v),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 35.h),
                    child: Text(
                      "XX min ",
                      style: CustomTextStyles.titleLargeBlack90001,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.v),
            Padding(
              padding: EdgeInsets.only(left: 14.h),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgSettingsBlack9000129x22,
                    width: 22.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 36.h,
                      top: 2.v,
                      bottom: 2.v,
                    ),
                    child: Text(
                      "A lot of nature ",
                      style: CustomTextStyles.titleLargeBlack90001,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.v),
            Padding(
              padding: EdgeInsets.only(left: 13.h),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgLaptop,
                    width: 24.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 35.h,
                      bottom: 3.v,
                    ),
                    child: Text(
                      "Mainly gravel",
                      style: CustomTextStyles.titleLargeBlack90001,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.v),
            Padding(
              padding: EdgeInsets.only(left: 3.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 31.v,
                    width: 187.h,
                    margin: EdgeInsets.only(bottom: 1.v),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.imgGroup2,
                          height: 30.v,
                          alignment: Alignment.topLeft,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 157.h,
                            margin: EdgeInsets.only(
                              left: 30.h,
                              top: 5.v,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 1.v),
                                  child: Text(
                                    "XX m",
                                    style:
                                        CustomTextStyles.titleLargeBlack90001,
                                  ),
                                ),
                                Text(
                                  "XX m",
                                  style: CustomTextStyles.titleLargeBlack90001,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7.v),
                    child: Text(
                      "Very flat",
                      style: CustomTextStyles.titleLargeBlack90001Light,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 55.v),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildSaveTrail(BuildContext context) {
    return CustomElevatedButton(
      height: 80.v,
      text: "Save trail",
      margin: EdgeInsets.only(
        left: 20.h,
        right: 20.h,
        bottom: 26.v,
      ),
      rightIcon: Container(
        margin: EdgeInsets.only(left: 30.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgPlus,
          height: 26.adaptSize,
          width: 26.adaptSize,
        ),
      ),
      buttonStyle: CustomButtonStyles.fillGreenTL10,
    );
  }
}
