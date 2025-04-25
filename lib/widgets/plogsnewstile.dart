import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/articlemodel.dart';
import 'package:url_launcher/url_launcher.dart';

class PlogsNewsTile extends StatelessWidget {
  const PlogsNewsTile({super.key, required this.articlemodel});
  final Articlemodel articlemodel;

  Future<void> _launchURL(BuildContext context) async {
    final url = articlemodel.url;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No URL available')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL: ${e.toString()}')),
      );
    }
  }

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
        onTap: () => _launchURL(context),
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