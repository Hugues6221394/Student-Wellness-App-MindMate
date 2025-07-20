import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WellnessGoal {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime targetDate;
  final int progress;
  final bool isCompleted;

  WellnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    this.progress = 0,
    this.isCompleted = false,
  });
}

class WellnessGoalsScreen extends StatefulWidget {
  const WellnessGoalsScreen({super.key});

  @override
  State<WellnessGoalsScreen> createState() => _WellnessGoalsScreenState();
}

class _WellnessGoalsScreenState extends State<WellnessGoalsScreen> {
  final List<WellnessGoal> _goals = [
    WellnessGoal(
      id: '1',
      title: 'Daily Mindfulness Practice',
      description: 'Engage in 10 minutes of meditation or deep breathing exercises daily',
      category: 'Mindfulness',
      targetDate: DateTime.now().add(const Duration(days: 30)),
      progress: 70,
    ),
    WellnessGoal(
      id: '2',
      title: 'Sleep Hygiene Improvement',
      description: 'Maintain consistent sleep schedule with 7-8 hours nightly',
      category: 'Health',
      targetDate: DateTime.now().add(const Duration(days: 21)),
      progress: 45,
    ),
    WellnessGoal(
      id: '3',
      title: 'Stress Management',
      description: 'Implement stress reduction techniques to maintain emotional balance',
      category: 'Mental Health',
      targetDate: DateTime.now().add(const Duration(days: 60)),
      progress: 60,
    ),
    WellnessGoal(
      id: '4',
      title: 'Social Engagement',
      description: 'Participate in peer support discussions weekly',
      category: 'Social',
      targetDate: DateTime.now().add(const Duration(days: 45)),
      progress: 30,
    ),
  ];

  final List<String> _categories = [
    'Mindfulness',
    'Health',
    'Mental Health',
    'Social',
    'Academic',
    'Personal',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Wellness Objectives'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddGoalDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFF2E7D32),
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.insights,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Wellness Progress Overview',
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Completion Rate',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_calculateOverallProgress()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Objectives',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_goals.where((goal) => !goal.isCompleted).length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Goals List
            Text(
              'Your Wellness Objectives',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ..._goals.map((goal) => _buildGoalCard(goal)).toList(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(WellnessGoal goal) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final progressColor = _getProgressColor(goal.progress);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
          children: [
      Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(goal.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(goal.category),
                  color: _getCategoryColor(goal.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      goal.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editGoal(goal);
                  } else if (value == 'delete') {
                    _deleteGoal(goal);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text('Modify', style: TextStyle(color: Color(0xFF2E7D32))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            goal.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completion',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${goal.progress}%',
                    style: TextStyle(
                      color: progressColor,
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
                  widthFactor: goal.progress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Goal Info
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                daysLeft > 0 ? '$daysLeft days remaining' : 'Target date passed',
                style: TextStyle(
                  color: daysLeft > 0 ? Colors.grey[600] : Colors.red,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Achieved',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),

    // Action Buttons
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: const BorderRadius.only(
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
    ),
    ),
    child: Row(
    children: [
    Expanded(
    child: OutlinedButton.icon(
    onPressed: () => _updateProgress(goal),
    icon: const Icon(Icons.trending_up, size: 18),
    label: const Text('Update', style: TextStyle(fontSize: 14)),
    style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF2E7D32),
    side: const BorderSide(color: Color(0xFF2E7D32)),
    padding: const EdgeInsets.symmetric(vertical: 8),
    ),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: ElevatedButton.icon(
    onPressed: () => _completeGoal(goal),
    icon: const Icon(Icons.check, size: 18),
    label: const Text('Complete', style: TextStyle(fontSize: 14)),
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF388E3C),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    ),
    ),
    ),
    ],
    ),
    ),
      ],
    ),
    );
  }

  Color _getProgressColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return const Color(0xFF43A047);
    if (progress >= 40) return const Color(0xFF7CB342);
    return const Color(0xFFE53935);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mindfulness': return const Color(0xFF0288D1);
      case 'Health': return const Color(0xFF2E7D32);
      case 'Mental Health': return const Color(0xFF7B1FA2);
      case 'Social': return const Color(0xFFEF6C00);
      case 'Academic': return const Color(0xFFC2185B);
      case 'Personal': return const Color(0xFF00897B);
      default: return const Color(0xFF2E7D32);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mindfulness': return Icons.self_improvement;
      case 'Health': return Icons.health_and_safety;
      case 'Mental Health': return Icons.psychology;
      case 'Social': return Icons.people_alt;
      case 'Academic': return Icons.school;
      case 'Personal': return Icons.person_outline;
      default: return Icons.flag;
    }
  }

  int _calculateOverallProgress() {
    if (_goals.isEmpty) return 0;
    final totalProgress = _goals.fold(0, (sum, goal) => sum + goal.progress);
    return (totalProgress / _goals.length).round();
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Objective'),
        content: const Text('Objective creation will be available in the next update'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Objective creation coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editGoal(WellnessGoal goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Objective modification coming soon')),
    );
  }

  void _deleteGoal(WellnessGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Objective'),
        content: Text('Confirm removal of "${goal.title}" objective?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _goals.removeWhere((g) => g.id == goal.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Objective removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _updateProgress(WellnessGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current completion: ${goal.progress}%'),
            const SizedBox(height: 16),
            Slider(
              value: goal.progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  final index = _goals.indexWhere((g) => g.id == goal.id);
                  if (index != -1) {
                    _goals[index] = WellnessGoal(
                      id: goal.id,
                      title: goal.title,
                      description: goal.description,
                      category: goal.category,
                      targetDate: goal.targetDate,
                      progress: value.round(),
                      isCompleted: goal.isCompleted,
                    );
                  }
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress updated')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _completeGoal(WellnessGoal goal) {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = WellnessGoal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          category: goal.category,
          targetDate: goal.targetDate,
          progress: 100,
          isCompleted: true,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Objective achieved: "${goal.title}"')),
    );
  }
}