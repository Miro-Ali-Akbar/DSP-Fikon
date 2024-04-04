import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart';

// ignore: must_be_immutable
class ChallengecardsItemWidget extends StatelessWidget {
  ChallengecardsItemWidget({
    Key? key,
    this.onTapChallengeCard,
  }) : super(
          key: key,
        );

  VoidCallback? onTapChallengeCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320.h,
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            onTapChallengeCard?.call();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14.h,
              vertical: 7.v,
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
                  "Challenge",
                  style: theme.textTheme.headlineSmall,
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
                        padding: EdgeInsets.only(
                          top: 7.v,
                          bottom: 3.v,
                        ),
                        child: Text(
                          "n.n km left",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgSettings,
                        width: 20.h,
                        margin: EdgeInsets.only(left: 36.h),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 7.h,
                          top: 7.v,
                          bottom: 1.v,
                        ),
                        child: Text(
                          "2 days",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgArrowRight,
                        height: 21.v,
                        margin: EdgeInsets.only(
                          left: 51.h,
                          top: 7.v,
                          bottom: 3.v,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
