import 'widgets/trailspagemytrails_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart'; // ignore_for_file: must_be_immutable

class TrailsPageMyTrailsPage extends StatelessWidget {
  const TrailsPageMyTrailsPage({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SizedBox(
          width: SizeUtils.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 19.v),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 644.v,
                        width: 320.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 88.v),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _buildNavigationButtons(
                                        context,
                                        ticket:
                                            ImageConstant.imgSettingsGreen600,
                                        challenge: "Trails",
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildNavigationButtons(
                                        context,
                                        ticket: ImageConstant.imgTicket,
                                        challenge: "Challenge",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            _buildTrailspageMytrails(context)
                          ],
                        ),
                      ),
                      SizedBox(height: 18.v),
                      _buildSavedTrail(
                        context,
                        imageFour: ImageConstant.imgImage3,
                        trailName: "Trail name",
                        trailInfo: "Trail info",
                      ),
                      SizedBox(height: 18.v),
                      _buildSavedTrail(
                        context,
                        imageFour: ImageConstant.imgImage4,
                        trailName: "Trail name",
                        trailInfo: "Trail info",
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildTrailspageMytrails(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 18.v,
          );
        },
        itemCount: 4,
        itemBuilder: (context, index) {
          return TrailspagemytrailsItemWidget(
            onTapSavedTrail: () {
              onTapSavedTrail(context);
            },
          );
        },
      ),
    );
  }

  /// Common widget
  Widget _buildNavigationButtons(
    BuildContext context, {
    required String ticket,
    required String challenge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7.h,
        vertical: 2.v,
      ),
      decoration: AppDecoration.fillGreen,
      child: Column(
        children: [
          SizedBox(height: 8.v),
          CustomImageView(
            imagePath: ticket,
            height: 29.v,
          ),
          SizedBox(height: 7.v),
          Text(
            challenge,
            style: CustomTextStyles.bodyLarge16.copyWith(
              color: theme.colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }

  /// Common widget
  Widget _buildSavedTrail(
    BuildContext context, {
    required String imageFour,
    required String trailName,
    required String trailInfo,
  }) {
    return Container(
      decoration: AppDecoration.fillGreen.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageView(
            imagePath: imageFour,
            height: 150.v,
            radius: BorderRadius.horizontal(
              left: Radius.circular(10.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 1.h),
            child: SizedBox(
              height: 150.v,
              child: VerticalDivider(
                width: 1.h,
                thickness: 1.v,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 13.h,
              top: 11.v,
              bottom: 80.v,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trailName,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 5.v),
                Text(
                  trailInfo,
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Navigates to the individualTrailPageScreen when the action is triggered.
  onTapSavedTrail(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.individualTrailPageScreen);
  }
}
