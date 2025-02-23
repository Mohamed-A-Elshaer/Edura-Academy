import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/ReviewsScreen.dart';
import 'package:mashrooa_takharog/widgets/CourseOnAction.dart';
import 'package:mashrooa_takharog/widgets/customElevatedBtn.dart';

class WriteReviewScreen extends StatefulWidget{
  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {

  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  int _maxChars = 131;
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       leading: IconButton(
           icon: const Icon(Icons.arrow_back),
           onPressed: (){
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ReviewsScreen()));
           }
       ),
       title: const Text('Write a Review'),



     ),

     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(20.0),
         child: Column(
       
       
           children: [
       CourseOnAction(),
         SizedBox(height: 40,),
         Align(
             alignment: Alignment.centerLeft,
             child: Text('Write your Review',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 18,fontWeight: FontWeight.w600),)),
       
             SizedBox(height: 30,),
             Container(
           height: 160,
           width: 360,
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withOpacity(0.2),
                 spreadRadius: 1,
                 blurRadius: 6,
                 offset: Offset(4, 4),
               ),
             ],
           ),
       
               child: Padding(
                 padding: const EdgeInsets.all(10.0),
                 child: Stack(
                   children: [
                     TextField(
                       controller: _controller,
                       maxLines: null,
                       maxLength: _maxChars, // Prevents exceeding character limit
                       onChanged: (text) {
                         setState(() {
                           _isTyping = text.isNotEmpty;
                         });
                       },
                       decoration: InputDecoration(
                         hintText: _isTyping ? '' : 'Write your comment here...',
                         border: InputBorder.none,
                         counterText: '', // Hides default Flutter counter
                       ),
                     ),
                     Positioned(
                       bottom: 8,
                       right: 8,
                       child: Text(
                         '${_maxChars - _controller.text.length} characters left',
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 12,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
         ),
             SizedBox(height: 50,),
             CustomElevatedBtn(btnDesc: 'Submit Review',horizontalPad: 40,)
           ],
         ),
       ),
     ),

   );
  }
}