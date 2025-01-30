import 'package:flutter/material.dart';

Future<void> loadingDialog({
  required BuildContext context,
}) async {
  showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return const PopScope(
          canPop: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.green),
                backgroundColor: Color.fromARGB(255, 220, 237, 200),
                strokeWidth: 5.0,
              ),
            ],
          ),
        );
      });
}
