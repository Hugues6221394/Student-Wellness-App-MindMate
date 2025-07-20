import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../providers/mood_provider.dart';
import 'mood_history_screen.dart';
import '../providers/auth_provider.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? selectedMood;
  int intensity = 3;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // Dark chocolate color palette
  final Color darkChocolate = const Color(0xFF2E7D32);
  final Color mediumChocolate = const Color(0xFF4CAF50);
  final Color lightChocolate = const Color(0xFF81C784);
  final Color creamWhite = const Color(0xFFF5F5F0);

  final List<String> moodTypes = [
    'Happy', 'Sad', 'Angry', 'Anxious', 'Tired',
    'Excited', 'Peaceful', 'Stressed', 'Grateful', 'Lonely'
  ];

  final Map<String, IconData> moodIcons = {
    'Happy': Icons.sentiment_very_satisfied,
    'Sad': Icons.sentiment_very_dissatisfied,
    'Angry': Icons.sentiment_dissatisfied,
    'Anxious': Icons.sentiment_neutral,
    'Tired': Icons.bedtime,
    'Excited': Icons.celebration,
    'Peaceful': Icons.spa,
    'Stressed': Icons.psychology,
    'Grateful': Icons.favorite,
    'Lonely': Icons.person_off,
  };

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    // This will be called when the screen loads to show recent moods
  }

  Future<void> _saveMood() async {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a mood first'),
          backgroundColor: mediumChocolate,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String userId = 'current_user_id';

      if (authProvider.isAuthenticated && authProvider.user != null) {
        userId = authProvider.user!.uid;
      } else {
        await authProvider.signInAnonymously();
        if (authProvider.user != null) {
          userId = authProvider.user!.uid;
        }
      }

      final mood = Mood(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: DateTime.now(),
        moodType: selectedMood!,
        intensity: intensity,
        notes: _notesController.text.trim(),
      );

      await moodProvider.addMood(mood);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Mood saved successfully!'),
            backgroundColor: mediumChocolate,
          ),
        );
        setState(() {
          selectedMood = null;
          intensity = 3;
          _notesController.clear();
        });
      }
    } catch (e) {
      debugPrint('MoodScreen: Error saving mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save mood: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: creamWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with chocolate gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkChocolate, mediumChocolate],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mediumChocolate.withOpacity(0.3),
                          ),
                          child: Icon(
                              Icons.emoji_emotions,
                              size: 48,
                              color: creamWhite
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Log Your Mood',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: creamWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'How are you feeling today?',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: creamWhite.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MoodHistoryScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                                Icons.history,
                                color: creamWhite,
                                size: 24
                            ),
                            tooltip: 'View Mood History',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Recent Moods Section
                      Consumer<MoodProvider>(
                        builder: (context, moodProvider, child) {
                          final recentMoods = moodProvider.moods.take(3).toList();
                          if (recentMoods.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Moods',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: mediumChocolate,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: creamWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: darkChocolate.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                        color: mediumChocolate.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    children: recentMoods.map((mood) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: mediumChocolate.withOpacity(0.1),
                                        child: Icon(
                                          moodIcons[mood.moodType] ?? Icons.emoji_emotions,
                                          color: mediumChocolate,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        mood.moodType,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: darkChocolate,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${mood.date.day}/${mood.date.month}/${mood.date.year} - Intensity: ${mood.intensity}',
                                        style: TextStyle(
                                          color: lightChocolate,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: mediumChocolate.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: mediumChocolate.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          '${mood.intensity}/5',
                                          style: TextStyle(
                                            color: mediumChocolate,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Mood chips
                      Text(
                        'Select Your Mood',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: mediumChocolate,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 10.0,
                        children: moodTypes.map((mood) => ChoiceChip(
                          avatar: Icon(
                            moodIcons[mood] ?? Icons.emoji_emotions,
                            color: selectedMood == mood ? creamWhite : mediumChocolate,
                            size: 18,
                          ),
                          label: Text(mood),
                          labelStyle: TextStyle(
                            color: selectedMood == mood ? creamWhite : mediumChocolate,
                            fontWeight: FontWeight.w600,
                          ),
                          selected: selectedMood == mood,
                          selectedColor: mediumChocolate,
                          backgroundColor: mediumChocolate.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                                color: mediumChocolate.withOpacity(0.3)),
                          ),
                          onSelected: (selected) => setState(() => selectedMood = mood),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        )).toList(),
                      ),
                      const SizedBox(height: 28),

                      // Intensity slider
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: creamWhite,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: darkChocolate.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: mediumChocolate.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bolt, color: mediumChocolate),
                                const SizedBox(width: 8),
                                Text('Intensity: $intensity',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: mediumChocolate,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: intensity.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              activeColor: mediumChocolate,
                              inactiveColor: mediumChocolate.withOpacity(0.3),
                              onChanged: (value) => setState(() => intensity = value.toInt()),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Low',
                                  style: TextStyle(
                                      color: lightChocolate,
                                      fontSize: 12
                                  ),
                                ),
                                Text('High',
                                  style: TextStyle(
                                      color: lightChocolate,
                                      fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Notes field
                      Container(
                        decoration: BoxDecoration(
                          color: creamWhite,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: darkChocolate.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: mediumChocolate.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Any notes about your mood? (Optional)',
                            labelStyle: TextStyle(color: lightChocolate),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                            hintText: 'What\'s on your mind?',
                            hintStyle: TextStyle(color: lightChocolate.withOpacity(0.5)),
                          ),
                          maxLines: 3,
                          style: TextStyle(color: darkChocolate),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveMood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumChocolate,
                            foregroundColor: creamWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Save Mood',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Overlay back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: creamWhite.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                    Icons.arrow_back,
                    color: darkChocolate
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final scaffoldState = Scaffold.of(context);
          if (scaffoldState.hasDrawer) {
            scaffoldState.openDrawer();
          }
        },
        backgroundColor: mediumChocolate,
        child: Icon(
            Icons.menu,
            color: creamWhite
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}