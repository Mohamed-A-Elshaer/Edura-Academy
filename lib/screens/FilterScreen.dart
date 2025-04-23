import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/search_courses_page.dart';
import 'package:mashrooa_takharog/widgets/CustomCheckBox.dart';
import 'package:mashrooa_takharog/widgets/CustomFilterCheckBox.dart';
import 'package:mashrooa_takharog/widgets/CustomFilterModel.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class FilterScreen extends StatefulWidget{
  final Map<String, dynamic>? initialFilters;
  const FilterScreen({super.key, this.initialFilters});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> selectedCategories = [];
  List<String> selectedPrices = [];
  List<String> selectedRatings = [];
  List<String> selectedDurations = [];

  List<String> title=[
    'SubCategories',
    'Price',
    'Video Durations'
    '',
    'Rating'

  ];

  List<String> subCategoriesList=[
    'Graphic Design',
'Programming',
    'Cooking',
    'Finance and Accounting' ,
    'SEO & Marketing',
    'Arts & Humanities' ,
    'Personal Development' ,
    'Office Productivity'
  ];

  /*List<String> levels=[
    'All Levels',
    'Beginners',
    'Intermediate',
    'Expert',
  ];*/
  List<String> price=[
    'Paid',
    'Free',
     ];

  List<String> rating=[
    '4.5 & Up Above',
    '4.0 & Up Above',
    '3.5 & Up Above',
    '3.0 & Up Above',
    '2.5 & Up Above',
    '2.0 & Up Above',
    '1.5 & Up Above',
    '1.0 & Up Above',
  ];

  List<String> videoDuration=[
    '0-5 Minutes',
    '5-10 Minutes',
    '10-30 Minutes',
    '30+ Minutes',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize from initialFilters if they exist
    if (widget.initialFilters != null) {
      selectedCategories = List<String>.from(widget.initialFilters!['categories'] ?? []);
      selectedPrices = List<String>.from(widget.initialFilters!['prices'] ?? []);
      selectedRatings = List<String>.from(widget.initialFilters!['ratings'] ?? []);
      selectedDurations = List<String>.from(widget.initialFilters!['durations'] ?? []);
    }
  }


  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _togglePrice(String price) {
    setState(() {
      if (selectedPrices.contains(price)) {
        selectedPrices.remove(price);
      } else {
        selectedPrices.add(price);
      }
    });
  }

  void _toggleRating(String rating) {
    setState(() {
      if (selectedRatings.contains(rating)) {
        selectedRatings.remove(rating);
      } else {
        selectedRatings.add(rating);
      }
    });
  }

  void _toggleDuration(String duration) {
    setState(() {
      if (selectedDurations.contains(duration)) {
        selectedDurations.remove(duration);
      } else {
        selectedDurations.add(duration);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCategories.clear();
      selectedPrices.clear();
      selectedRatings.clear();
      selectedDurations.clear();
    });
  }



  @override
  Widget build(BuildContext context) {
return Scaffold(
  backgroundColor: Color(0xffF5F9FF),
  appBar: AppBar(
    leading: IconButton(onPressed: (){Navigator.pop(context);},
        icon: Icon(CupertinoIcons.arrow_left,color: Colors.black,)),
    title: Text('Filter',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),

    backgroundColor:Color(0xffF5F9FF) ,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 30),
        child: GestureDetector(
          onTap: _clearFilters,
          child: Text('Clear',style: TextStyle(color: Color(0xff545454),fontFamily: 'Jost',fontSize: 16,fontWeight: FontWeight.w600),),
        ),
      )

    ],
  ),

  body: Stack(
    children:[
      Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: SingleChildScrollView(
        child: Column(

          children: [
           CustomFilterModel(title: title[0], itemCount: subCategoriesList.length, checkBoxItem: subCategoriesList,containerHeight: 330,selectedItems: selectedCategories, onToggle: _toggleCategory,),
            CustomFilterModel(title: title[1], itemCount: price.length, checkBoxItem: price,containerHeight: 100,selectedItems: selectedPrices, onToggle: _togglePrice,),
            CustomFilterModel(title: title[2], itemCount: videoDuration.length, checkBoxItem: videoDuration,containerHeight: 180, selectedItems: selectedDurations, onToggle: _toggleDuration,),
            CustomFilterModel(title: title[3], itemCount: rating.length, checkBoxItem: rating,containerHeight: 330,selectedItems: selectedRatings, onToggle: _toggleRating,),
           // CustomFilterModel(title: title[1], itemCount: levels.length, checkBoxItem: levels,containerHeight: 180,),











          ],

        ),
      ),
    ),
      Align(
        alignment: Alignment.bottomCenter,
        child: CustomElevatedBtn(btnDesc: 'Apply',horizontalPad: 89,onPressed: (){ Navigator.pop(context, {
    'categories': selectedCategories,
    'prices': selectedPrices,
    'ratings': selectedRatings,
    'durations': selectedDurations,
    });}),
      )
    ]
  ),
);
  }
}