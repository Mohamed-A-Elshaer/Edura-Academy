import 'package:flutter/material.dart';

class Notificationpage extends StatelessWidget {
  const Notificationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Today'),
            _buildNotificationCard(
              icon: Icons.category,
              title: 'New Category Course..!',
              description: 'The 3D Design Course is now available.',
            ),
            _buildNotificationCard(
              icon: Icons.category,
              title: 'New Category Course..!',
              description: 'The 3D Design Course is now available.',
            ),
            _buildNotificationCard(
              icon: Icons.local_offer,
              title: 'Today’s Special Offers',
              description: 'You have made a course payment.',
            ),

            _buildSectionTitle('Yesterday'),
            _buildNotificationCard(
              icon: Icons.credit_card,
              title: 'Credit Card Connected..!',
              description: 'Your credit card has been linked.',
            ),

            _buildSectionTitle('Nov 20, 2022'),
            _buildNotificationCard(
              icon: Icons.account_circle,
              title: 'Account Setup Successful..!',
              description: 'Your account has been created.',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the section title
  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // Helper widget to build individual notification cards
  static Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                icon,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
