import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/widgets/CurriculumSectionLessonModel.dart';
import 'package:mashrooa_takharog/widgets/CurriculumSectionTitleModel.dart';

class CurriculumScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

  return Scaffold(
    backgroundColor: Color(0xffF5F9FF),
    appBar: AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){}
      ),
      title: const Text('Curriculum'),
    ),
    body: Center(
    child: Container(
      margin: EdgeInsets.only(top: 20),
    height: double.infinity,
    width: 350,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(11),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          offset: Offset(1, 1),
        ),
      ],

    ),
      child: SingleChildScrollView(
        child: Column(
            children: [
        
              CurriculumSectionTitleModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionTitleModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionLessonModel(),
              CurriculumSectionTitleModel(),
        
        
            ],
          ),
      ),


        )
    )

  );
  }


}