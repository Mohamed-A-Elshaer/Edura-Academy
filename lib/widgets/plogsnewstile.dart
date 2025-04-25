import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/articlemodel.dart';

import 'package:url_launcher/url_launcher.dart';

class PlogsNewsTile extends StatelessWidget {
  const PlogsNewsTile({super.key, required this.articlemodel});
  final Articlemodel articlemodel;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          articlemodel.image ??
              'https://cdn-jjfhf.nitrocdn.com/hwGdHsKTGpIHJSBirKPhKvQbhZYuIuNn/assets/images/optimized/rev-6de35dd/almdrasa.com/wp-content/uploads/2022/10/7e7d8f24-eee2-4400-b0a6-2a3bbd8fef30.jpg',
          height: 500,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://cdn-icons-png.flaticon.com/512/2748/2748558.png',
              height: 500,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Text(
        articlemodel.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        articlemodel.subtitle ?? 'There are not exist subtitle',
        maxLines: 2,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final uri = Uri.tryParse(articlemodel.url ?? '');
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid or unavailable URL')),
            );
          }
        },
        child: Text(
          'Read more',
          style: TextStyle(
            color: Colors.blue[900],
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      )
    ]);
  }
}
