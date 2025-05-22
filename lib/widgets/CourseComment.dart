import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseComment extends StatefulWidget {
  final String userName;
  final double rating;
  final String comment;
  final String timestamp;
  final String? supabaseUserId;
  final String userId;
  final String? currentUserId;
  final VoidCallback onDelete;

  const CourseComment({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.supabaseUserId,
    required this.userId,
    required this.onDelete,
    required this.currentUserId,
  });

  @override
  State<CourseComment> createState() => _CourseCommentState();
}

class _CourseCommentState extends State<CourseComment> {
  bool isExpanded = false;
  String? _imageUrl;

  bool get isCurrentUser {
    return widget.currentUserId != null &&
        widget.userId != null &&
        widget.currentUserId == widget.userId;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileAvatar();
  }

  Future<void> _fetchProfileAvatar() async {
    final supabase = Supabase.instance.client;
    try {
      final imagePath = '${widget.supabaseUserId}/profile';

      final files = await supabase.storage
          .from('profiles')
          .list(path: widget.supabaseUserId!);

      final fileExists = files.any((file) => file.name == 'profile');

      if (!fileExists) {
        setState(() {
          _imageUrl = null;
        });
        return;
      }

      String imageUrl =
      supabase.storage.from('profiles').getPublicUrl(imagePath);
      imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString()
      }).toString();

      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print("Error fetching avatar: $e");
      setState(() {
        _imageUrl = null;
      });
    }
  }

  String _formatTimeAgo(String isoDate) {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldShowSeeAll = widget.comment.length > 131;
    final displayedText = isExpanded
        ? widget.comment
        : (shouldShowSeeAll ? widget.comment.substring(0, 120) + '...' : widget.comment);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.2),
            radius: 23,
            child: _imageUrl != null
                ? ClipOval(
              child: Image.network(
                _imageUrl!,
                height: 46,
                width: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person, color: Colors.grey),
              ),
            )
                : const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Right content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.userName,
                        style: const TextStyle(
                          fontFamily: 'Jost',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffE8F1FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xff4D81E5), width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 17),
                          const SizedBox(width: 2),
                          Text(
                            widget.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Jost',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff202244),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Comment + see all
                Text(
                  displayedText,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff545454),
                  ),
                ),
                if (shouldShowSeeAll)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Text(
                      isExpanded ? 'See Less' : 'See All',
                      style: const TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Delete + timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isCurrentUser)
                      TextButton(
                        onPressed: widget.onDelete,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xff202244),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Mulish',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    Text(
                      _formatTimeAgo(widget.timestamp),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        color: Color(0xff202244),
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
}
