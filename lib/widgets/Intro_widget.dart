import 'package:flutter/cupertino.dart';

class IntroWidget extends StatelessWidget{
  String titleText, descriptionText;
   IntroWidget({super.key,required this.titleText,required this.descriptionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(titleText,style: TextStyle(fontFamily: 'Jost',fontSize: 24,color: Color(0xff202244)),textAlign: TextAlign.center,),
          SizedBox(height: 23,),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 0),
            child: Text(descriptionText,
              style: TextStyle(fontFamily: 'Mulish',fontSize: 14,color: Color(0xff545454)),
              textAlign: TextAlign.center,
            ),
          ),
        ],

      ),
    );
  }
  
  
  
}