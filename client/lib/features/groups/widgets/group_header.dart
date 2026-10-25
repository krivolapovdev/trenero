import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/groups/widgets/group_popup_menu.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const Color expandedColor = Color(0xFFCABEE4);
  static const double contentHeight = 136.0;

  final GroupSummaryResponse group;
  final double topPadding;
  final bool isRefreshing;

  const new({
    required this.group,
    required this.topPadding,
    this.isRefreshing = false,
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

    final hasNote = group.note != null && group.note!.trim().isNotEmpty;

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
                            group.name,
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
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CardBadge(
                                icon: const Icon(
                                  CupertinoIcons.rectangle_stack_person_crop,
                                ),
                                label: '${group.countOfStudents}',
                                backgroundColor: colorScheme.primaryContainer
                                    .withValues(alpha: 0.6),
                                foregroundColor: colorScheme.onPrimaryContainer,
                              ),
                              if (group.defaultPrice != null) ...[
                                const SizedBox(width: 8),
                                CardBadge(
                                  icon: const Icon(CupertinoIcons.tags),
                                  label: group.defaultPrice!.toFormattedAmount(
                                    showSign: false,
                                  ),
                                  backgroundColor: const Color(0xFFE8F5E9)
                                      .withValues(alpha: 0.6),
                                  foregroundColor: const Color(0xFF2E7D32),
                                ),
                              ],
                            ],
                          ),
                          if (hasNote) ...[
                            const SizedBox(height: 6),
                            Text(
                              group.note!,
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
                          group.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                actions: [
                  GroupPopupMenu(group: group),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant GroupHeaderDelegate oldDelegate) =>
      oldDelegate.group != group ||
      oldDelegate.topPadding != topPadding ||
      oldDelegate.isRefreshing != isRefreshing;
}
