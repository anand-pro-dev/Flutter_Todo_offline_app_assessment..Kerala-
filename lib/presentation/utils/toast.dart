import 'package:flutter/material.dart';
// import 'package:harmonity_app/constants.dart';

void showCustomNotification(context, msg, {Color? color}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top:
              MediaQuery.of(context).padding.top +
              45, // Position below the status bar
          left: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey.shade200,
                  //       borderRadius: BorderRadius.circular(12)),
                  //   padding: EdgeInsets.all(10),
                  //   child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(12),
                  //       child: Image.asset(
                  //         "assets/images/logo/logo_white.png",
                  //         height: 25,
                  //         width: 25,
                  //       )),
                  // ),
                  // SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      msg ?? "",
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );

  overlay?.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
