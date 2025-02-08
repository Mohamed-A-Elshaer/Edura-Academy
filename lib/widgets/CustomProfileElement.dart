import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProfileElement extends StatelessWidget{
  String text;
  IconData icon;
  GestureTapCallback onTap;
   CustomProfileElement({super.key,required this.text,required this.icon,required this.onTap});
  @override
  Widget build(BuildContext context) {
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 25.0),
  child: GestureDetector(
    onTap: onTap,
    child: Row(

      children: [
        Icon(icon,color: Colors.black,),
        SizedBox(width: 10,),
        Text(text,style: TextStyle(fontFamily: 'Mulish',fontSize: 15,fontWeight: FontWeight.w700,color: Color(0xff202244)),),
        Spacer(),
        Icon(Icons.keyboard_arrow_right_outlined,color: Colors.black,size: 37,),
      ],
    ),
  ),
);
  }

}