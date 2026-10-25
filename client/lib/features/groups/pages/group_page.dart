import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/header_bottom_spacer.dart';
import 'package:phone/core/widgets/header_snap_scroll_physics.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/pages/group_students_page.dart';
import 'package:phone/features/groups/widgets/group_header.dart';
import 'package:phone/features/groups/widgets/group_lessons_section.dart';
import 'package:phone/features/groups/widgets/group_students_section.dart';
import 'package:phone/generated/export.dart';

class GroupPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage> {
  late GroupSummaryResponse _group = widget.group;
  late final ScrollController _scrollController = ScrollController();
  bool _isSnapping = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openGroupStudentsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => GroupStudentsPage(group: _group)),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _snapIfNeeded();
      });
    }
    return false;
  }

  void _snapIfNeeded() {
    if (!mounted || !_scrollController.hasClients || _isSnapping) return;
    final position = _scrollController.position;

    // Do not snap if overscrolling (pull-to-refresh)
    if (position.outOfRange) return;

    final offset = position.pixels;
    const snapOffset = GroupHeaderDelegate.contentHeight;

    if (offset > 1.0 && offset < snapOffset - 1.0) {
      final target = offset < (snapOffset / 2) ? 0.0 : snapOffset;
      _isSnapping = true;
      _scrollController
          .animateTo(
            target,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            _isSnapping = false;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroupRefreshing = ref.watch(
      groupListControllerProvider.select((state) => state.isLoading),
    );

    ref.listen(groupListControllerProvider, (previous, next) {
      final updated = (next.value ?? const <GroupSummaryResponse>[])
          .where((group) => group.id == _group.id)
          .firstOrNull;

      if (updated != null) {
        setState(() => _group = updated);
      }
    });

    final topPadding = MediaQuery.paddingOf(context).top;
    final headerMaxHeight =
        topPadding + kToolbarHeight + GroupHeaderDelegate.contentHeight;

    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: CustomMaterialIndicator(
          edgeOffset: headerMaxHeight,
          displacement: 20,
          color: Colors.black,
          clipBehavior: Clip.antiAlias,
          onRefresh: () async {
            await Future.wait([
              ref.read(groupLessonsProvider(_group.id).notifier).refresh(),
              ref.read(groupStudentsProvider(_group.id).notifier).refresh(),
              ref
                  .read(groupListControllerProvider.notifier)
                  .getAllGroups(forceRefresh: true),
            ]);

            if (!context.mounted) return;

            final listState = ref.read(groupListControllerProvider);
            if (listState.hasError) return;

            final updated = (listState.value ?? const [])
                .where((g) => g.id == _group.id)
                .firstOrNull;

            if (updated == null) {
              Navigator.of(context).pop();
              return;
            }

            setState(() => _group = updated);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              controller: _scrollController,
              clipBehavior: Clip.none,
              physics: const HeaderSnapScrollPhysics(
                snapOffset: GroupHeaderDelegate.contentHeight,
                parent: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: GroupHeaderDelegate(
                    group: _group,
                    topPadding: topPadding,
                    isRefreshing: isGroupRefreshing,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      GroupLessonsSection(
                        groupId: _group.id,
                        groupName: _group.name,
                      ),
                      const SizedBox(height: 16),
                      GroupStudentsSection(
                        groupId: _group.id,
                        studentCount: _group.countOfStudents == 0
                            ? null
                            : _group.countOfStudents,
                        onEdit: _openGroupStudentsPage,
                      ),
                    ],
                  ),
                ),
                const HeaderBottomSpacer(
                  snapOffset: GroupHeaderDelegate.contentHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
