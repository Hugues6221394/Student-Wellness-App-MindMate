import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/meditation_provider.dart';

class ProfileStatisticsScreen extends StatefulWidget {
  const ProfileStatisticsScreen({super.key});

  @override
  State<ProfileStatisticsScreen> createState() => _ProfileStatisticsScreenState();
}

class _ProfileStatisticsScreenState extends State<ProfileStatisticsScreen> {
  String _selectedPeriod = 'Today';

  final List<String> _periods = ['Today', 'This week', 'This Month', 'This Year', 'All Time'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Performance Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Frame',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _periods.map((period) {
                        final isSelected = _selectedPeriod == period;
                        return ChoiceChip(
                          label: Text(period),
                          selected: isSelected,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                          selectedColor: const Color(0xFF388E3C),
                          backgroundColor: const Color(0xFFE8F5E9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPeriod = period;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emotional State Statistics
            _buildStatisticsCard(
              'Emotional State Analysis',
              Icons.emoji_emotions,
              const Color(0xFF43A047),
              [
                _buildStatItem('Average Emotional State', '5.2/10', 'Positive'),
                _buildStatItem('Total Entries', '64', 'This week'),
                _buildStatItem('Peak Day', 'Friday', '9/10'),
                _buildStatItem('Lowest Day', 'Monday', '5.2/10'),
              ],
            ),
            const SizedBox(height: 16),

            // Reflection Statistics
            _buildStatisticsCard(
              'Reflection Activity',
              Icons.book,
              const Color(0xFF2E7D32),
              [
                _buildStatItem('Journal Entries', '12', 'This month'),
                _buildStatItem('Words Documented', '2,847', 'Avg 237/entry'),
                _buildStatItem('Longest Reflection', '1,234 words', 'March 15'),
                _buildStatItem('Most Active Day', 'Friday', '3 entries'),
              ],
            ),
            const SizedBox(height: 16),

            // Mindfulness Statistics
            _buildStatisticsCard(
              'Mindfulness Practice',
              Icons.self_improvement,
              const Color(0xFF4CAF50),
              [
                _buildStatItem('Completed Sessions', '15', 'This month'),
                _buildStatItem('Total Duration', '400 min', 'Avg 15min/session'),
                _buildStatItem('Longest Session', '45 minutes', 'May 20'),
                _buildStatItem('Current Streak', '7 days', 'Personal best'),
              ],
            ),
            const SizedBox(height: 16),

            // Wellness Score
            _buildWellnessScoreCard(),
            const SizedBox(height: 16),

            // Progress Charts
            _buildProgressChartCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(String title, IconData icon, Color color, List<Widget> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...stats,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScoreCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF2E7D32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Wellness Index',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '8.4/10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Excellent Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '+12%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChartCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Weekly Engagement',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bars
            _buildProgressBar('Emotional Tracking', 0.85, const Color(0xFF43A047)),
            const SizedBox(height: 12),
            _buildProgressBar('Reflection Journal', 0.72, const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            _buildProgressBar('Mindfulness', 0.68, const Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            _buildProgressBar('Peer Support', 0.45, const Color(0xFF81C784)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}