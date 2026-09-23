import 'package:flutter/material.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';
import 'package:intervuex_app/core/widgets/app_button.dart';
import 'package:intervuex_app/data/services/api_service.dart';
import 'package:intervuex_app/data/services/firebase_service.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool confirmed = false;
  bool isDeleting = false;

  Future<void> _delete() async {
    if (!confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check the confirmation box to proceed.')),
      );
      return;
    }

    setState(() => isDeleting = true);
    try {
      await ApiService.instance.deleteAccount('user_current');
      setState(() => isDeleting = false);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Account Scheduled for Deletion'),
          content: const Text(
            'Your account data, resumes, mock interview audio recordings, and study plans have been purged per our data safety and privacy policy.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await FirebaseService.instance.signOut();
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => isDeleting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
                SizedBox(width: 10),
                Text('Delete Your IntervueX Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Deleting your account is permanent. In compliance with Google Play Store User Data & Privacy policies, the following actions will take place immediately:',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 16),

            _bullet('Uploaded resumes, project claims, and parsing caches will be permanently deleted.'),
            _bullet('All recorded voice mock interview audio and evaluation history will be wiped.'),
            _bullet('Custom interview packs, bookmarked questions, and study plans will be removed.'),
            _bullet('Any active Google Play subscriptions must be cancelled separately in the Google Play Store to prevent future renewal charges.'),

            const SizedBox(height: 24),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I understand that this action is irreversible and permanently deletes all my career preparation data.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              value: confirmed,
              onChanged: (val) => setState(() => confirmed = val ?? false),
            ),

            const SizedBox(height: 24),
            AppButton(
              label: 'Permanently Delete My Account',
              variant: AppButtonVariant.danger,
              width: double.infinity,
              isLoading: isDeleting,
              onPressed: _delete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}
