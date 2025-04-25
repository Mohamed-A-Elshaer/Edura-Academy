import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/articlemodel.dart';
import 'package:mashrooa_takharog/widgets/plogsnewslistview.dart';
import 'package:mashrooa_takharog/widgets/plogsnewsserviece.dart';

class PlogsnewsListviewBuilder extends StatefulWidget {
  const PlogsnewsListviewBuilder({
    super.key,
    required this.catogery,
  });
  final String catogery;
  @override
  State<PlogsnewsListviewBuilder> createState() =>
      _PlogsnewsListviewBuilderState();
}

class _PlogsnewsListviewBuilderState extends State<PlogsnewsListviewBuilder> {
  var future;
  @override
  void initState() {
    super.initState();
    future = Plogsnewsserviece(Dio()).getNews(category: widget.catogery);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Articlemodel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PlogsNewsListView(
              articels: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return const SliverToBoxAdapter(
              child: Text('OPPS there is an Error , try later '),
            );
          } else {
            return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
