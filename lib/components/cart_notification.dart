import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

void showCartNotification(
  BuildContext context, {
  required String imageUrl,
  required String productName,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _CartNotificationWidget(
      imageUrl: imageUrl,
      productName: productName,
      onDismissed: () {
        overlayEntry.remove();
      },
    ),
  );

  overlay.insert(overlayEntry);
}

class _CartNotificationWidget extends StatefulWidget {
  final String imageUrl;
  final String productName;
  final VoidCallback onDismissed;

  const _CartNotificationWidget({
    required this.imageUrl,
    required this.productName,
    required this.onDismissed,
  });

  @override
  State<_CartNotificationWidget> createState() =>
      _CartNotificationWidgetState();
}

class _CartNotificationWidgetState extends State<_CartNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -2.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();

    // Auto-dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D201C).withValues(alpha: 0.1),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image Thumbnail
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFF0EE),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6961).withValues(alpha: 0.2),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Icon(
                          Icons.fastfood_rounded,
                          color: const Color(0xFFFF6961),
                          size: 20.r,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.fastfood_rounded,
                          color: const Color(0xFFFF6961),
                          size: 20.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Notification Text
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionado ao carrinho!   ',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.productName,
                          style: TextStyle(
                            color: const Color(0xFF5D201C),
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Success Check Icon
                  // Container(
                  //   padding: EdgeInsets.all(8.w),
                  //   decoration: const BoxDecoration(
                  //     color: Color(0xFF4CAF50),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: Icon(
                  //     Icons.check_rounded,
                  //     color: Colors.white,
                  //     size: 16.r,
                  //   ),
                  // ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
