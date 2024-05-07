import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GoBackButton extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(); 
            }, 
          
            icon: SvgPicture.asset('assets/icons/arrow-sm-left-svgrepo-com (1).svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)
            ),
          
            label: Text(''), 
          ),
        ),
      ],
    ); 
  }
}