import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurriculumSectionLessonModel extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    String title='Why using Graphic Designing';
    bool isLong= title.length>20;
   return Column(
     children: [
       Container(
         margin: EdgeInsets.symmetric(horizontal: 15),
         width: double.infinity,
         child: Row(
           children: [
             Container(
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(
                     color: Color(0xffE8F1FF),
                     width: 3,
                   ),
                 ),
                 child: CircleAvatar(
                   radius: 24,
                   backgroundColor: Color(0xffF5F9FF),
                   child: Text('01',style: TextStyle(fontFamily: 'Jost',fontSize: 14,fontWeight: FontWeight.w700,color: Color(0xff202244)),),

                 )
             ),
             SizedBox(width: 5,),
             Column(
               children: [
                 Text(isLong? title.substring(0,20)+'..':title,style: TextStyle(fontFamily: 'Jost',fontSize: 16,fontWeight: FontWeight.w600,color: Color(0xff202244)),),
                 Transform.translate(
                     offset: Offset(-64, 0),
                     child: const Text('15 mins',style: TextStyle(fontFamily: 'Mulish',fontSize: 13,fontWeight: FontWeight.w700,color: Color(0xff545454)),))

               ],

             ),
             SizedBox(width: 33,),
             IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.play_circle_fill,color: Color(0xff0961F5),))
           ],
         ),
       ),
       Padding(
         padding: EdgeInsets.only(top: 10),
         child: Divider(
           color: Color(0xffF5F9FF),
           thickness: 3,
           indent: 0,
           endIndent: 0,
         ),
       ),
     ],
   );
  }


}