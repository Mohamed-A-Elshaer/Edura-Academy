import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/articlemodel.dart';
import 'package:mashrooa_takharog/widgets/plogsnewstile.dart';

class PlogsNewsListView extends StatelessWidget {
  const PlogsNewsListView({
    super.key,
    required this.articels,
  });

  final List<Articlemodel> articels;

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(childCount: articels.length,
            (context, index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: PlogsNewsTile(
          articlemodel: articels[index],
        ),
      );
    }));
  }
}
