import 'package:trailquest_proto/widgets/app_bar/custom_app_bar.dart';
import 'package:trailquest_proto/widgets/app_bar/appbar_title.dart';
import 'widgets/challengecards_item_widget.dart';
import 'package:trailquest_proto/widgets/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class StartPage extends StatelessWidget {
  StartPage({Key? key})
      : super(
          key: key,
        );

  List<String> dropdownItemList = ["Item One", "Item Two", "Item Three"];

  List<String> dropdownItemList1 = ["Item One", "Item Two", "Item Three"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        appBar: _buildAppBar(context),
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              SizedBox(height: 23.v),
              _buildChallengeCards(context),
              SizedBox(height: 94.v),
              SizedBox(
                height: 470.v,
                width: double.maxFinite,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomDropDown(
                      width: 130.h,
                      icon: Container(
                        margin: EdgeInsets.fromLTRB(30.h, 6.v, 6.h, 6.v),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgArrowdown,
                          height: 18.adaptSize,
                          width: 18.adaptSize,
                        ),
                      ),
                      hintText: "Today",
                      hintStyle: theme.textTheme.bodyLarge!,
                      alignment: Alignment.topLeft,
                      items: dropdownItemList,
                      contentPadding: EdgeInsets.only(
                        left: 5.h,
                        top: 11.v,
                        bottom: 11.v,
                      ),
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgImage2,
                      width: 360.h,
                      alignment: Alignment.center,
                    ),
                    CustomDropDown(
                      width: 130.h,
                      icon: Container(
                        margin: EdgeInsets.fromLTRB(30.h, 6.v, 6.h, 6.v),
                        child: CustomImageView(
                          imagePath: ImageConstant.imgArrowdown,
                          height: 18.adaptSize,
                          width: 18.adaptSize,
                        ),
                      ),
                      hintText: "Today",
                      hintStyle: theme.textTheme.bodyLarge!,
                      alignment: Alignment.topLeft,
                      items: dropdownItemList1,
                      contentPadding: EdgeInsets.only(
                        left: 5.h,
                        top: 11.v,
                        bottom: 11.v,
                      ),
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgImage2,
                      width: 360.h,
                      alignment: Alignment.center,
                    ),
                    _buildNavigation(context)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 51.h,
      leading: Container(
        height: 46.adaptSize,
        width: 46.adaptSize,
        margin: EdgeInsets.only(
          left: 5.h,
          bottom: 21.v,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomImageView(
              imagePath: ImageConstant.imgSvgrepoIconcarrier,
              height: 46.adaptSize,
              width: 46.adaptSize,
              alignment: Alignment.center,
            ),
            CustomImageView(
              imagePath: ImageConstant.imgSvgrepoIconcarrier,
              height: 46.adaptSize,
              width: 46.adaptSize,
              alignment: Alignment.center,
            )
          ],
        ),
      ),
      title: Container(
        height: 63.000004.v,
        width: 176.99998.h,
        margin: EdgeInsets.only(left: 110.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppbarTitle(
              text: "TrailQuest",
            ),
            AppbarTitle(
              text: "TrailQuest",
            )
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildChallengeCards(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 140.v,
        child: ListView.separated(
          padding: EdgeInsets.only(left: 20.h),
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) {
            return SizedBox(
              width: 11.h,
            );
          },
          itemCount: 3,
          itemBuilder: (context, index) {
            return ChallengecardsItemWidget(
              onTapChallengeCard: () {
                onTapChallengeCard(context);
              },
            );
          },
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNavigation(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildNavigationButtons1(
                context,
                lock: ImageConstant.imgHome,
                profile: "Start",
              ),
            ),
            Expanded(
              child: _buildNavigationButtons(
                context,
                ticket: ImageConstant.imgSettingsPrimary,
                challenge: "Trails",
                onTapNavigationButtons: () {
                  onTapNavigationButtons(context);
                },
              ),
            ),
            Expanded(
              child: _buildNavigationButtons(
                context,
                ticket: ImageConstant.imgTicket,
                challenge: "Challenge",
              ),
            ),
            Expanded(
              child: _buildNavigationButtons1(
                context,
                lock: ImageConstant.imgLock,
                profile: "Profile",
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildNavigationButtons(
    BuildContext context, {
    required String ticket,
    required String challenge,
    Function? onTapNavigationButtons,
  }) {
    return GestureDetector(
      onTap: () {
        onTapNavigationButtons?.call();
      },
      child: Container(
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
            SizedBox(height: 6.v),
            Text(
              challenge,
              style: CustomTextStyles.bodyLarge16.copyWith(
                color: theme.colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildNavigationButtons1(
    BuildContext context, {
    required String lock,
    required String profile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.h,
        vertical: 7.v,
      ),
      decoration: AppDecoration.fillGreen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 2.v),
          CustomImageView(
            imagePath: lock,
            height: 30.adaptSize,
            width: 30.adaptSize,
          ),
          SizedBox(height: 4.v),
          Text(
            profile,
            style: CustomTextStyles.bodyLarge16.copyWith(
              color: theme.colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }

  /// Navigates to the checkpointChallengeScreen when the action is triggered.
  onTapChallengeCard(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.checkpointChallengeScreen);
  }

  onTapNavigationButtons(BuildContext context) {
    // TODO: implement Actions
  }
}
