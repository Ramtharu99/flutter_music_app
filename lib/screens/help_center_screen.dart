import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_app/services/connectivity_service.dart';
import 'package:music_app/utils/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  Future<void> _onRefresh() async {
    if (_connectivityService.isOffline) return;

    Future.delayed(const Duration(milliseconds: 500));
  }

  final List<Map<String, String>> _helpTopics = [
    {
      'title': 'How to Download Songs',
      'description':
          '1. Go to the Tuner screen.\n'
          '2. Tap the three-dot menu on a song.\n'
          '3. Select "Download".\n'
          '4. The song will be saved to your Offline section for later playback.',
    },
    {
      'title': 'How to Access Downloaded (Offline) Songs',
      'description':
          '1. Open the Tuner screen.\n'
          '2. Swipe the chip bar to the left.\n'
          '3. Tap on the "Offline" chip.\n'
          '4. All your downloaded songs will appear here and can be played without internet.',
    },
    {
      'title': 'How to Create a Playlist',
      'description':
          '1. Go to your Library.\n'
          '2. Tap "Create Playlist".\n'
          '3. Add songs from your favorites or search.',
    },
    {
      'title': 'How to Use the Search Feature',
      'description':
          '1. Tap the search icon.\n'
          '2. Type the song, album, or artist.\n'
          '3. Select from the results to play instantly.',
    },
    {
      'title': 'Account Settings',
      'description':
          '1. Tap on your profile.\n'
          '2. Go to Manage Account.\n'
          '3. Update name, email, password, and also profile image',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: Text(
          'Help Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Colors.black,
        onRefresh: _onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          itemCount: _helpTopics.length,
          itemBuilder: (context, index) {
            final topic = _helpTopics[index];
            return _buildHelpCard(topic['title']!, topic['description']!);
          },
        ),
      ),
    );
  }

  Widget _buildHelpCard(String title, String description) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
