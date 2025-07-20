import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meditation_session.dart';
import '../providers/meditation_provider.dart';
import 'meditation_session_screen.dart';
import 'meditation_history_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  String selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll events if needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final scaffoldState = Scaffold.of(context);
          if (scaffoldState.hasDrawer) {
            scaffoldState.openDrawer();
          }
        },
        backgroundColor: const Color(0xFF2E7D32), // Dark chocolate
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      body: Consumer<MeditationProvider>(
        builder: (context, meditationProvider, child) {
          final sessions = meditationProvider.sessions;
          final completedSessions = meditationProvider.completedSessions;
          final totalMinutes = meditationProvider.getTotalMinutesCompleted();
          final averageRating = meditationProvider.getAverageRating();

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar with header
              SliverAppBar(
                expandedHeight: 220,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32), // Dark chocolate
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.self_improvement,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mindful Moments',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Find peace in every breath',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _QuickStartCard(),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SliverList(
                delegate: SliverChildListDelegate([
                  // Progress section
                  if (completedSessions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _ProgressCard(
                        totalMinutes: totalMinutes,
                        averageRating: averageRating,
                        sessionCount: completedSessions.length,
                      ),
                    ),
                  ],

                  // Categories filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _CategoryFilter(
                      selectedCategory: selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sessions header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Guided Sessions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MeditationHistoryScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                          ),
                          child: const Row(
                            children: [
                              Text('History'),
                              SizedBox(width: 4),
                              Icon(Icons.history, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),

              // Sessions grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final filteredSessions = selectedCategory == 'All'
                          ? sessions
                          : sessions.where((s) => s.category == selectedCategory).toList();
                      final session = filteredSessions[index];
                      return _MeditationSessionCard(session: session);
                    },
                    childCount: selectedCategory == 'All'
                        ? sessions.length
                        : sessions.where((s) => s.category == selectedCategory).length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.play_circle_filled,
                color: Color(0xFF2E7D32), size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Start',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Begin your mindfulness journey',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final meditationProvider = Provider.of<MeditationProvider>(context, listen: false);
                if (meditationProvider.sessions.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MeditationSessionScreen(session: meditationProvider.sessions.first),
                    ),
                  );
                }
              },
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int totalMinutes;
  final double averageRating;
  final int sessionCount;

  const _ProgressCard({
    required this.totalMinutes,
    required this.averageRating,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  'Your Journey',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.timer,
                  value: '$totalMinutes',
                  label: 'Minutes',
                  color: const Color(0xFF8B5A2B),
                ),
                _StatItem(
                  icon: Icons.self_improvement,
                  value: '$sessionCount',
                  label: 'Sessions',
                  color: const Color(0xFFA67C52),
                ),
                if (averageRating > 0)
                  _StatItem(
                    icon: Icons.star,
                    value: averageRating.toStringAsFixed(1),
                    label: 'Rating',
                    color: const Color(0xFFD2B48C),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: sessionCount / 20, // Progress based on sessions completed
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF2E7D32),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(sessionCount / 20 * 100).toStringAsFixed(0)}% of monthly goal',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const _CategoryFilter({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Calm', 'Sleep', 'Relax', 'Focus', 'Breath'].map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF3A1F04),
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: const Color(0xFF2E7D32),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onSelected: (selected) {
                    if (selected) {
                      onCategoryChanged(category);
                    }
                  },
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MeditationSessionCard extends StatelessWidget {
  final MeditationSession session;

  const _MeditationSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeditationSessionScreen(session: session),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  session.category,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title and premium badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (session.isPremium)
                    const Icon(Icons.workspace_premium,
                        color: Color(0xFFD2B48C), size: 20),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                session.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Duration and play button
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16,
                      color: Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                  Text(
                    '${session.durationMinutes} min',
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}