import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import 'edit_journal_screen.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'This Week', 'This Month', 'Last 3 Months'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<JournalEntry> _getFilteredEntries(List<JournalEntry> allEntries) {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return allEntries.where((entry) => entry.date.isAfter(weekAgo)).toList();
      case 'This Month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return allEntries.where((entry) => entry.date.isAfter(monthAgo)).toList();
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return allEntries.where((entry) => entry.date.isAfter(threeMonthsAgo)).toList();
      default:
        return allEntries;
    }
  }

  List<JournalEntry> _getSearchResults(List<JournalEntry> entries) {
    if (_searchController.text.isEmpty) return entries;
    return entries.where((entry) =>
    entry.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        entry.content.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32), // Dark chocolate
        foregroundColor: Colors.white,
        title: const Text('Journal History'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final journalProvider = Provider.of<JournalProvider>(context, listen: false);
              final testEntries = [
                JournalEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: 'test_user',
                  date: DateTime.now().subtract(const Duration(days: 1)),
                  title: 'My First Journal Entry',
                  content: 'Today was a great day! I learned a lot and felt productive.',
                ),
                JournalEntry(
                  id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
                  userId: 'test_user',
                  date: DateTime.now().subtract(const Duration(days: 2)),
                  title: 'Reflections on Learning',
                  content: 'I\'ve been thinking about my progress and what I want to achieve next.',
                ),
              ];

              for (final entry in testEntries) {
                await journalProvider.addEntry(entry);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added test journal entries')),
                );
              }
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Add Test Data',
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          final allEntries = journalProvider.entries;
          final filteredEntries = _getFilteredEntries(allEntries);
          final searchResults = _getSearchResults(filteredEntries);

          return Column(
            children: [
              // Search and filter section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search journal entries...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                        suffixIcon: _isSearching
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFF2E7D32)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => ChoiceChip(
                          label: Text(filters[index]),
                          selected: selectedFilter == filters[index],
                          selectedColor: const Color(0xFF2E7D32),
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: selectedFilter == filters[index]
                                ? Colors.white
                                : const Color(0xFF2E7D32),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedFilter = filters[index];
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics card
              if (filteredEntries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.article,
                            value: '${filteredEntries.length}',
                            label: 'Entries',
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          _StatItem(
                            icon: Icons.calendar_today,
                            value: filteredEntries.isNotEmpty
                                ? '${filteredEntries.first.date.day}/${filteredEntries.first.date.month}/${filteredEntries.first.date.year}'
                                : 'No entries',
                            label: 'Latest',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Journal entries list
              Expanded(
                child: searchResults.isEmpty
                    ? _buildEmptyState(_isSearching)
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = searchResults[index];
                    return _JournalEntryCard(entry: entry);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No entries found' : 'No journal entries yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try adjusting your search terms'
                  : 'Start writing to see your entries here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
          child: const Icon(
            Icons.article,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        subtitle: Text(
          '${entry.date.day}/${entry.date.month}/${entry.date.year} at ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.content,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditJournalScreen(entry: entry),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteDialog(context, entry),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<JournalProvider>(context, listen: false).deleteEntry(entry.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete journal entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}