import 'package:flutter/cupertino.dart';

class CurriculumSectionTitleModel extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
return Padding(
  padding: const EdgeInsets.all(22.0),
  child: Row(
    children: [
      Text('Section 01 -',style: TextStyle(color: Color(0xff202244),fontSize: 15,fontFamily: 'Jost',fontWeight: FontWeight.w700),),
      Text(' Introduction',style: TextStyle(color: Color(0xff0961F5),fontSize: 15,fontFamily: 'Jost',fontWeight: FontWeight.w700),),
      SizedBox(width: 75,),
      Text('55 min',style: TextStyle(color: Color(0xff0961F5),fontSize: 12,fontFamily: 'Mulish',fontWeight: FontWeight.w800),),
    ],
  ),
);
  }


}