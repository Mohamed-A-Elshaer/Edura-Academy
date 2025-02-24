import 'package:flutter/cupertino.dart';

class CurriculumSectionTitleModel extends StatelessWidget {
  const CurriculumSectionTitleModel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(22.0),
      child: Row(
        children: [
          Text(
            'Section 01 -',
            style: TextStyle(
                color: Color(0xff202244),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w700),
          ),
          Text(
            ' Introduction',
            style: TextStyle(
                color: Color(0xff0961F5),
                fontSize: 15,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            width: 75,
          ),
          Text(
            '55 min',
            style: TextStyle(
                color: Color(0xff0961F5),
                fontSize: 12,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
