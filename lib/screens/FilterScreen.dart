import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/widgets/CustomCheckBox.dart';
import 'package:mashrooa_takharog/widgets/CustomFilterCheckBox.dart';
import 'package:mashrooa_takharog/widgets/CustomFilterModel.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class FilterScreen extends StatelessWidget {
  List<String> title = [
    'SubCategories',
    'Price',
    'Features',
    'Rating',
    'Video Durations'
  ];
  List<String> subCategoriesList = [
    '3D Design',
    'Web Development',
    '3D Animation',
    'Graphic Design',
    'SEO & Marketing',
    'Arts & Humanities'
  ];
  /*List<String> levels=[
    'All Levels',
    'Beginners',
    'Intermediate',
    'Expert',
  ];*/

  List<String> price = [
    'Paid',
    'Free',
  ];

  List<String> rating = [
    '4.5 & Up Above',
    '4.0 & Up Above',
    '3.5 & Up Above',
    '3.0 & Up Above',
  ];
  List<String> videoDuration = [
    '0-2 Hours',
    '3-6 Hours',
    '7-16 Hours',
    '17+ Hours',
  ];

  FilterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchCoursesPage()));
            },
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            )),
        title: const Text(
          'Filter',
          style: TextStyle(
              color: Color(0xff202244),
              fontFamily: 'Jost',
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xffF5F9FF),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Clear',
                style: TextStyle(
                    color: Color(0xff545454),
                    fontFamily: 'Jost',
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomFilterModel(
                    title: title[0],
                    itemCount: subCategoriesList.length,
                    checkBoxItem: subCategoriesList),
                // CustomFilterModel(title: title[1], itemCount: levels.length, checkBoxItem: levels,containerHeight: 180,),
                CustomFilterModel(
                  title: title[2],
                  itemCount: price.length,
                  checkBoxItem: price,
                  containerHeight: 100,
                ),
                CustomFilterModel(
                  title: title[4],
                  itemCount: rating.length,
                  checkBoxItem: rating,
                  containerHeight: 180,
                ),
                CustomFilterModel(
                  title: title[5],
                  itemCount: videoDuration.length,
                  checkBoxItem: videoDuration,
                  containerHeight: 180,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomElevatedBtn(
            btnDesc: 'Apply',
            horizontalPad: 89,
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchCoursesPage()));
            },
          ),
        )
      ]),
    );
  }
}
