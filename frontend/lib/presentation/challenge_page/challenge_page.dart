import 'package:trailquest_proto/widgets/custom_elevated_button.dart';
import 'widgets/forty_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart'; // ignore_for_file: must_be_immutable

class ChallengePage extends StatelessWidget {
  const ChallengePage({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: Container(
          width: double.maxFinite,
          decoration: AppDecoration.fillPrimary,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSix(context),
                _buildFive(context),
                SizedBox(height: 17.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard1(
                    context,
                    challenge: "Challenge",
                    mNCheckpoints: "m/n checkpoints",
                    onTapChallengeCard1: () {
                      onTapChallengeCard(context);
                    },
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard(
                    context,
                    challenge: "Challenge",
                    mNSteps: "n.n km left",
                    duration: "2 days",
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard(
                    context,
                    challenge: "Challenge",
                    mNSteps: "m/n steps",
                    duration: "5 hours",
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard1(
                    context,
                    challenge: "Challenge",
                    mNCheckpoints: "m/n checkpoints",
                    onTapChallengeCard1: () {
                      onTapChallengeCard1(context);
                    },
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard1(
                    context,
                    challenge: "Challenge",
                    mNCheckpoints: "m/n checkpoints",
                    onTapChallengeCard1: () {
                      onTapChallengeCard2(context);
                    },
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard2(
                    context,
                    challenge: "Challenge",
                    nNKmLeft: "m/n steps",
                    duration: "5 hours",
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard2(
                    context,
                    challenge: "Challenge",
                    nNKmLeft: "n.n km left",
                    duration: "2 days",
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 23.h,
                    right: 17.h,
                  ),
                  child: _buildChallengeCard1(
                    context,
                    challenge: "Challenge",
                    mNCheckpoints: "m/n checkpoints",
                    onTapChallengeCard1: () {
                      onTapChallengeCard3(context);
                    },
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
  Widget _buildSix(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgSvgrepoIconcarrier,
            height: 46.adaptSize,
            width: 46.adaptSize,
            margin: EdgeInsets.only(bottom: 29.v),
          ),
          Expanded(
            child: CustomElevatedButton(
              text: "Leaderboard",
              margin: EdgeInsets.only(
                left: 31.h,
                top: 9.v,
                bottom: 7.v,
              ),
              rightIcon: Container(
                margin: EdgeInsets.only(left: 26.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgGroup,
                  height: 37.v,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildFive(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.h,
        vertical: 5.v,
      ),
      decoration: AppDecoration.fillGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomElevatedButton(
                  height: 26.v,
                  width: 90.h,
                  text: "Not started",
                  margin: EdgeInsets.only(top: 9.v),
                  buttonStyle: CustomButtonStyles.fillPrimary,
                  buttonTextStyle: theme.textTheme.bodySmall!,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10.v),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.h,
                    vertical: 3.v,
                  ),
                  decoration: AppDecoration.outlinePrimary.copyWith(
                    borderRadius: BorderRadiusStyle.roundedBorder10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Clear ",
                        style: CustomTextStyles.bodySmallPrimary,
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgArrowRightPrimary,
                        height: 8.adaptSize,
                        width: 8.adaptSize,
                        margin: EdgeInsets.only(
                          left: 23.h,
                          top: 4.v,
                          bottom: 3.v,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 6.v),
          Padding(
            padding: EdgeInsets.only(left: 10.h),
            child: Wrap(
              runSpacing: 8.v,
              spacing: 8.h,
              children: List<Widget>.generate(6, (index) => FortyItemWidget()),
            ),
          ),
          SizedBox(height: 13.v)
        ],
      ),
    );
  }

  /// Common widget
  Widget _buildChallengeCard(
    BuildContext context, {
    required String challenge,
    required String mNSteps,
    required String duration,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.h,
        vertical: 7.v,
      ),
      decoration: AppDecoration.fillDeepPurple.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.v),
          Text(
            challenge,
            style: theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 51.v),
          Padding(
            padding: EdgeInsets.only(
              left: 4.h,
              right: 2.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.v),
                  child: Text(
                    mNSteps,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Spacer(
                  flex: 48,
                ),
                CustomImageView(
                  imagePath: ImageConstant.imgSettings,
                  width: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 7.h,
                    top: 8.v,
                  ),
                  child: Text(
                    duration,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Spacer(
                  flex: 51,
                ),
                CustomImageView(
                  imagePath: ImageConstant.imgArrowRight,
                  height: 21.v,
                  margin: EdgeInsets.only(
                    top: 7.v,
                    bottom: 4.v,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Common widget
  Widget _buildChallengeCard1(
    BuildContext context, {
    required String challenge,
    required String mNCheckpoints,
    Function? onTapChallengeCard1,
  }) {
    return GestureDetector(
      onTap: () {
        onTapChallengeCard1?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.h,
          vertical: 6.v,
        ),
        decoration: AppDecoration.fillIndigo.copyWith(
          borderRadius: BorderRadiusStyle.roundedBorder15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 11.v),
            Text(
              challenge,
              style: theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 58.v),
            Padding(
              padding: EdgeInsets.only(
                left: 4.h,
                right: 2.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mNCheckpoints,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgArrowRight,
                    height: 21.v,
                    margin: EdgeInsets.only(bottom: 5.v),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildChallengeCard2(
    BuildContext context, {
    required String challenge,
    required String nNKmLeft,
    required String duration,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.h,
        vertical: 6.v,
      ),
      decoration: AppDecoration.fillDeepOrange.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.v),
          Text(
            challenge,
            style: theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 48.v),
          Padding(
            padding: EdgeInsets.only(left: 4.h),
            child: Row(
              children: [
                SizedBox(
                  height: 34.v,
                  width: 146.h,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          nNKmLeft,
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgSettings,
                        width: 20.h,
                        alignment: Alignment.topRight,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 7.h,
                    top: 7.v,
                    bottom: 9.v,
                  ),
                  child: Text(
                    duration,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Spacer(),
                CustomImageView(
                  imagePath: ImageConstant.imgArrowRight,
                  height: 21.v,
                  margin: EdgeInsets.only(
                    top: 7.v,
                    bottom: 5.v,
                  ),
                )
              ],
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

  /// Navigates to the checkpointChallengeScreen when the action is triggered.
  onTapChallengeCard1(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.checkpointChallengeScreen);
  }

  /// Navigates to the checkpointChallengeScreen when the action is triggered.
  onTapChallengeCard2(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.checkpointChallengeScreen);
  }

  /// Navigates to the checkpointChallengeScreen when the action is triggered.
  onTapChallengeCard3(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.checkpointChallengeScreen);
  }
}
