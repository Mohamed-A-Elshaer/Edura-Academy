import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/plogscatogrycardlistview.dart';
import 'package:mashrooa_takharog/widgets/plogsnewslistviewbuilder.dart';

class PlogsPage extends StatelessWidget {
  const PlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BLOGS",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                "Welcome to our Blogs",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Pacifico",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            SliverToBoxAdapter(
              child: PlogsCategoryCardListview(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 32,
              ),
            ),
            PlogsnewsListviewBuilder(
              catogery: 'Programming%20language',
            ),
          ],
        ),
      ),
    );
  }
}
