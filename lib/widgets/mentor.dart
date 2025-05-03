import 'package:flutter/material.dart';

class MentorCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const MentorCard({
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
