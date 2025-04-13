import 'package:flutter/material.dart';
import 'video_player_screen.dart';

class CourseLessonsScreen extends StatelessWidget {
  final String courseTitle;

  const CourseLessonsScreen({
    super.key,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Section 01: Introduction',
        'duration': '25 Mins',
        'lessons': [
          {
            'number': '01',
            'title': 'Why Using Graphic De...',
            'duration': '15 Mins',
            'isCompleted': true,
            'videoId': 'video_001',
          },
          {
            'number': '02',
            'title': 'Setup Your Graphic De...',
            'duration': '10 Mins',
            'isCompleted': true,
            'videoId': 'video_002',
          },
        ],
      },
      {
        'title': 'Section 02: Graphic Design',
        'duration': '54 Mins',
        'lessons': [
          {
            'number': '03',
            'title': 'Take a Look Graphic De...',
            'duration': '20 Mins',
            'isLocked': true,
            'videoId': 'video_003',
          },
          {
            'number': '04',
            'title': 'Working with Graphic De...',
            'duration': '22 Mins',
            'isLocked': true,
            'videoId': 'video_004',
          },
          {
            'number': '05',
            'title': 'Working with Frame & Lay...',
            'duration': '12 Mins',
            'isLocked': true,
            'videoId': 'video_005',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          courseTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = sections[sectionIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            section['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            section['duration'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (section['lessons'] as List).length,
                      itemBuilder: (context, lessonIndex) {
                        final lesson = section['lessons'][lessonIndex];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: Text(
                              lesson['number'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xff0961F5),
                              ),
                            ),
                            title: Text(
                              lesson['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              lesson['duration'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lesson['isCompleted'] == true
                                    ? const Color(0xff0961F5)
                                    : Colors.grey[200],
                              ),
                              child: Icon(
                                lesson['isLocked'] == true
                                    ? Icons.lock
                                    : lesson['isCompleted'] == true
                                        ? Icons.play_arrow
                                        : Icons.play_arrow,
                                color: lesson['isCompleted'] == true
                                    ? Colors.white
                                    : const Color(0xff0961F5),
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              final bool isLocked = lesson['isLocked'] ?? false;
                              if (!isLocked) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerScreen(
                                      lessonTitle: lesson['title'] ?? '',
                                      videoUrl: lesson['videoUrl'] ?? '',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle continue course
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0961F5),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continue Course',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
