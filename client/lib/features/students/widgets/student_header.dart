import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/features/students/extensions/student_status_extension.dart';
import 'package:phone/features/students/widgets/student_badges.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const Color expandedColor = Color(0xFFCABEE4);
  static const double contentHeight = 136.0;

  final StudentSummaryResponse student;
  final double topPadding;
  final bool isRefreshing;
  final Widget? menu;

  const new({
    required this.student,
    required this.topPadding,
    this.isRefreshing = false,
    this.menu,
  });

  @override
  double get minExtent => topPadding + kToolbarHeight;

  @override
  double get maxExtent => topPadding + kToolbarHeight + contentHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxShrink = maxExtent - minExtent;
    final progress = maxShrink > 0
        ? (shrinkOffset / maxShrink).clamp(0.0, 1.0)
        : 0.0;

    // Smooth cross-fade between expanded and collapsed states
    final expandedOpacity = (1.0 - progress * 1.5).clamp(0.0, 1.0);
    final collapsedOpacity = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);

    final curveProgress = Curves.easeInOut.transform(progress);
    final headerColor = Color.lerp(
      expandedColor,
      colorScheme.surface,
      curveProgress,
    )!;

    final badges = student.statuses.toBadges(context);
    final hasNote = student.note != null && student.note!.trim().isNotEmpty;
    final hasPhone = student.phone != null && student.phone!.isNotEmpty;

    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Material(
        color: headerColor,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Expanded header content (large centered title & badges)
            if (expandedOpacity > 0)
              Positioned(
                top: topPadding + kToolbarHeight,
                left: 16,
                right: 16,
                height: contentHeight,
                child: Opacity(
                  opacity: expandedOpacity,
                  child: IgnorePointer(
                    ignoring: expandedOpacity < 0.2,
                    child: Skeletonizer(
                      enabled: isRefreshing,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          if (badges.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            StudentBadges(badges: badges),
                          ],
                          if (hasPhone) ...[
                            const SizedBox(height: 6),
                            Text(
                              student.phone!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ] else if (hasNote) ...[
                            const SizedBox(height: 6),
                            Text(
                              student.note!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Collapsed / Pinned App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: minExtent,
              child: AppBar(
                systemOverlayStyle: overlayStyle,
                primary: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: const BackButton(),
                title: collapsedOpacity > 0
                    ? Opacity(
                        opacity: collapsedOpacity,
                        child: Text(
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                actions: [?menu, const SizedBox(width: 8)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StudentHeaderDelegate oldDelegate) =>
      oldDelegate.student != student ||
      oldDelegate.topPadding != topPadding ||
      oldDelegate.isRefreshing != isRefreshing ||
      oldDelegate.menu != menu;
}
