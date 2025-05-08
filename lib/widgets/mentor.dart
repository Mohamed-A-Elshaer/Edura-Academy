import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/mentorProfile.dart';

class MentorCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String mentorId;
  final int courseCount;
  final int studentCount;
  final String major;
  final String title;

  const MentorCard({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.mentorId,
    required this.courseCount,
    required this.studentCount,
    required this.major,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mentorprofile(
              mentorId: mentorId,
              name: name,
              imagePath: imagePath,
              courseCount: courseCount,
              studentCount: studentCount,
              major: major,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            ClipOval(
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/mentor.jpg',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      imagePath,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
