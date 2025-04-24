import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/plogscategorymodel.dart';
import 'package:mashrooa_takharog/widgets/plogscatogryview.dart';

class PlogsCateoryCard extends StatelessWidget {
  const PlogsCateoryCard({super.key, required this.model});
  final PlogsCategoryModel model;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return Plogscatogryview(
            catogery: model.name,
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Container(
            height: 100,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage(model.image)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                model.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )),
      ),
    );
  }
}
