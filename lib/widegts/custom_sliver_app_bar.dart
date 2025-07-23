import 'package:todozen/providers/todo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomSliverAppBar extends StatelessWidget {
  final TodoProvider provider;
  final TabController tabController;

  const CustomSliverAppBar({
    super.key,
    required this.provider,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDarkMode;
    final taskCount = provider.currentTabTodos.length;
    final tabIndex = provider.selectedTabIndex;
    final tabTitle = _getTabTitle(tabIndex);

    return SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
          labelStyle: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.white,
        ),
      ),
      actions: [
        // Theme toggle button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => provider.toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative bubbles
              Positioned(top: -20, right: -20, child: _buildBubble(80, 0.1)),
              Positioned(top: 60, left: 20, child: _buildBubble(40, 0.1)),
              Positioned(bottom: 40, right: 60, child: _buildBubble(30, 0.1)),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tab title
                      Text(
                            tabTitle,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            curve: Curves.easeOutQuad,
                            duration: 400.ms,
                          ),
                      const SizedBox(height: 8),
                      // Task count
                      Text(
                            '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms)
                          .slideY(
                            delay: 100.ms,
                            begin: 0.2,
                            end: 0,
                            curve: Curves.easeOutQuad,
                            duration: 400.ms,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  // Helper method to create decorative bubbles
  Widget _buildBubble(double size, double opacity) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(duration: (2000 + size * 10).ms, begin: 0, end: -10)
        .then()
        .moveY(duration: (2000 + size * 10).ms, begin: -10, end: 0);
  }

  // Helper method to get tab title
  String _getTabTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'Upcoming';
      case 2:
        return 'Completed';
      default:
        return 'Tasks';
    }
  }
}
