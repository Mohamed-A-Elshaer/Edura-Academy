import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/plogsnewslistviewbuilder.dart';

class Plogscatogryview extends StatelessWidget {
  const Plogscatogryview({super.key, required this.catogery});
  final String catogery;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          catogery,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          PlogsnewsListviewBuilder(
            catogery: catogery,
          )
        ],
      ),
    );
  }
}
