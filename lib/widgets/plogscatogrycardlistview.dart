import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/plogscategorymodel.dart';
import 'package:mashrooa_takharog/widgets/plogscatogrycard.dart';

class PlogsCategoryCardListview extends StatelessWidget {
  const PlogsCategoryCardListview({super.key});
  final List<PlogsCategoryModel> catogeries = const [
    PlogsCategoryModel(
        image: 'assets/images/flutter.png', name: 'Flutter language'),
    PlogsCategoryModel(
        image: 'assets/images/javascript.png', name: 'JavaScript'),
    PlogsCategoryModel(image: 'assets/images/python.png', name: 'Python'),
    PlogsCategoryModel(image: 'assets/images/software.jpeg', name: 'SoftWare'),
    PlogsCategoryModel(image: 'assets/images/Database.jpeg', name: 'DataBase'),
    PlogsCategoryModel(image: 'assets/images/AI.jpeg', name: 'AI')
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: catogeries.length,
        itemBuilder: (context, index) {
          return PlogsCateoryCard(
            model: catogeries[index],
          );
        },
      ),
    );
  }
}
