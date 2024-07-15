import 'package:dignify/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final String loadingText;

  const LoadingIndicatorWidget({
    super.key,
    this.loadingText = "Please wait a moment....",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SpinKitWave(
            color: primaryColor,
            size: 40.0,
          ),
          const SizedBox(height: 15.0),
          Text(
            loadingText,
            style: const TextStyle(
              fontSize: 12.0,
              color: primaryColor,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
