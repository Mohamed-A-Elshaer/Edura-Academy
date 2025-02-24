import 'package:flutter/cupertino.dart';

import 'CustomFilterCheckBox.dart';

class CustomFilterModel extends StatelessWidget {
  double? containerHeight;
  String title;
  int itemCount;
  List<String> checkBoxItem;
  CustomFilterModel(
      {super.key,
      required this.title,
      required this.itemCount,
      required this.checkBoxItem,
      this.containerHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff202244)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: SizedBox(
            height: containerHeight ?? 260,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: CustomFilterCheckBox(
                    text: checkBoxItem[index],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
