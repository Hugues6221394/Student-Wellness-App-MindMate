import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyReminders = true;
  bool _weeklyReports = false;
  bool _anonymousMode = false;
  String _language = 'English';
  String _theme = 'System';

  final List<String> _languages = ['English', 'French', 'Kinyarwanda'];
  final List<String> _themes = ['Light', 'Dark', 'System'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Application Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Application Configuration
            _buildSectionCard(
              'Application Configuration',
              Icons.settings_applications,
              [
                _buildSwitchTile(
                  'Dark Theme',
                  'Enable dark interface',
                  Icons.dark_mode,
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                        },
                        activeColor: const Color(0xFF388E3C),
                      );
                    },
                  ),
                ),
                _buildDropdownTile(
                  'Language Preference',
                  'Select application language',
                  Icons.language,
                  _language,
                  _languages,
                      (value) => setState(() => _language = value!),
                ),
                _buildDropdownTile(
                  'Theme Preference',
                  'Select interface theme',
                  Icons.palette,
                  _theme,
                  _themes,
                      (value) => setState(() => _theme = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Settings
            _buildSectionCard(
              'Notification Preferences',
              Icons.notifications_active,
              [
                _buildSwitchTile(
                  'Enable Notifications',
                  'Receive system notifications',
                  Icons.notifications,
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                    activeColor: const Color(0xFF388E3C),
                  ),
                ),
                _buildSwitchTile(
                  'Daily Wellness Reminders',
                  'Receive daily check-in prompts',
                  Icons.schedule,
                  Switch(
                    value: _dailyReminders,
                    onChanged: (value) => setState(() => _dailyReminders = value),
                    activeColor: const Color(0xFF388E3C),
                  ),
                ),
                _buildSwitchTile(
                  'Weekly Analytics Reports',
                  'Receive weekly performance summaries',
                  Icons.assessment,
                  Switch(
                    value: _weeklyReports,
                    onChanged: (value) => setState(() => _weeklyReports = value),
                    activeColor: const Color(0xFF388E3C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy Configuration
            _buildSectionCard(
              'Privacy Configuration',
              Icons.security,
              [
                _buildSwitchTile(
                  'Anonymous Engagement',
                  'Hide personal identifiers',
                  Icons.visibility_off,
                  Switch(
                    value: _anonymousMode,
                    onChanged: (value) => setState(() => _anonymousMode = value),
                    activeColor: const Color(0xFF388E3C),
                  ),
                ),
                _buildListTile(
                  'Data Export',
                  'Download your wellness records',
                  Icons.download,
                      () => _exportData(),
                ),
                _buildListTile(
                  'Privacy Policy',
                  'Review our data policies',
                  Icons.privacy_tip,
                      () => _showPrivacyPolicy(),
                ),
                _buildListTile(
                  'Terms of Service',
                  'View application terms',
                  Icons.description,
                      () => _showTermsOfService(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Management
            _buildSectionCard(
              'Account Management',
              Icons.manage_accounts,
              [
                _buildListTile(
                  'Update Credentials',
                  'Change password or email',
                  Icons.lock_reset,
                      () => _changePassword(),
                ),
                _buildListTile(
                  'Deactivate Account',
                  'Permanently remove your account',
                  Icons.delete_forever,
                      () => _deleteAccount(),
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Support & Information
            _buildSectionCard(
              'Support & Information',
              Icons.help_outline,
              [
                _buildListTile(
                  'Support Center',
                  'Access help resources',
                  Icons.help_center,
                      () => _openHelpCenter(),
                ),
                _buildListTile(
                  'Contact Support',
                  'Send us a message',
                  Icons.contact_support,
                      () => _contactUs(),
                ),
                _buildListTile(
                  'Application Feedback',
                  'Rate and review',
                  Icons.star_rate,
                      () => _rateApp(),
                ),
                _buildListTile(
                  'About Application',
                  'Version and information',
                  Icons.info_outline,
                      () => _showAbout(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
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
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, Widget switchWidget) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: switchWidget,
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> options, Function(String?) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF2E7D32),
            size: 20
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Wellness Data'),
        content: const Text('Your wellness records will be compiled into a secure archive. Proceed with export?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting wellness data...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'We prioritize your data security. Collected information is used exclusively to enhance your wellness experience. We implement industry-standard encryption and never share personal data without explicit consent.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This application is provided for educational and wellness purposes. Users are responsible for maintaining the confidentiality of their credentials and for all activities that occur under their account.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credential update feature will be available in the next release')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Deletion'),
        content: const Text('This action permanently removes all your data and cannot be reversed. Confirm account deletion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion will be available in the next release')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support center will be available in the next release')),
    );
  }

  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact support will be available in the next release')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback system will be available in the next release')),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Wellness Companion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Developed to support student mental health through evidence-based wellness tracking, mindfulness exercises, and peer support networks.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('You will need to authenticate again to access your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}