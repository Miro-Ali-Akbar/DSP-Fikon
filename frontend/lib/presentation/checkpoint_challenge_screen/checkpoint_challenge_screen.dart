
import 'package:trailquest_proto/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart';

class CheckpointChallengeScreen extends StatelessWidget {
  const CheckpointChallengeScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 75.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: ()=>Navigator.pop(context),
                      icon: CustomImageView(
                        imagePath: ImageConstant.imgArrowDownBlack900,
                        height: 20.v,
                        margin: EdgeInsets.only(
                          left: 10.v,
                          right: 10.v,
                          top: 22.v,
                          bottom: 22.v,
                        ),
                      )
                    ),
                    
                    Container(
                      width: 170.h,
                      margin: EdgeInsets.only(
                        left: 35.h,
                        top: 16.v,
                      ),
                      child: Text(
                        "Checkpoint challenge",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.v),
              _buildDescription(context),
              //SizedBox(height: 15.v),
              //_buildOne(context),
              //Spacer(),
              //SizedBox(height: 79.v),
              CustomElevatedButton(
                height: 77.v,
                text: "Start challenge",
                margin: EdgeInsets.only(
                  left: 21.h,
                  right: 19.h,
                ),
                rightIcon: Container(
                  margin: EdgeInsets.only(left: 30.h),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgPlayffffff,
                    width: 25.h,
                  ),
                ),
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildDescription(BuildContext context) {
    return Container(
      height: 500.v,
      width: 330.h,
      margin: EdgeInsets.only(left: 21.h),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200.h,
              child: Text(
                "This is a challenge where you are going to gather checkpoints.\n\nWhen you press start, you will receive a trail leading to the first checkpoint. ",
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.bodyLargeBlack9000117,
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: 0,
            child: SizedBox(
              width: 303.h,
              child: Text(
                "When you have reached that location, you will receive the trail to the next checkpoint and so on. \n\nGood luck!",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.bodyLargeBlack9000117,
              ),
            )
          ),
          CustomImageView(
            imagePath: ImageConstant.imgSvgrepoIconcarrierOnprimary, // the picture of a crossroad sign
            width: 90.h,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(right: 10.h),
          ),
          Positioned(
            top: 420,
            left: -22,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 19.h,
                  vertical: 28.v,
                ),
                decoration: AppDecoration.outlineOnPrimary.copyWith(
                  borderRadius: BorderRadiusStyle.roundedBorder10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 3.h,
                        top: 14.v,
                        bottom: 9.v,
                      ),
                      child: Text(
                        "0/10 checkpoints",
                        style: CustomTextStyles.headlineSmallOnPrimary,
                      ),
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgUser,
                      width: 47.h,
                      margin: EdgeInsets.only(
                        left: 20.h,
                        top: 2.v,
                      ),
                    ),
                  ],
                ),
              ),
            )
          )
        ],
      ),
    );
  }

  /// Section Widget
  /*Widget _buildOne(BuildContext context) {
    return 
  }*/

}
