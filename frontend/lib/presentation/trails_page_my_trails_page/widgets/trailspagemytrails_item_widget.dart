import 'package:flutter/material.dart';
import 'package:trailquest_proto/core/app_export.dart';

// ignore: must_be_immutable
class TrailspagemytrailsItemWidget extends StatelessWidget {
  TrailspagemytrailsItemWidget({
    Key? key,
    this.onTapSavedTrail,
  }) : super(
          key: key,
        );

  VoidCallback? onTapSavedTrail;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          onTapSavedTrail?.call();
        },
        child: Container(
          decoration: AppDecoration.fillGreen.copyWith(
            borderRadius: BorderRadiusStyle.roundedBorder10,
          ),
          child: Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgImage1,
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
                  top: 10.v,
                  bottom: 83.v,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trail name",
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      "Trail info",
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
