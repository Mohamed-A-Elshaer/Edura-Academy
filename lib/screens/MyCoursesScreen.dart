import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCoursesScreen extends StatefulWidget{

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  TextEditingController _searchController =new TextEditingController();

 bool _showOngoing=false;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('My Courses',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),
       backgroundColor: Colors.transparent,
     ),
     body: Column(
       children: [
         Padding(
           padding: const EdgeInsets.all(16),
           child: TextField(
             controller: _searchController,
             decoration: InputDecoration(
               hintText: 'Search for...',
               prefixIcon: const Icon(Icons.search),
               suffixIcon: Container(
                 margin: const EdgeInsets.only(right: 8),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Container(
                       margin: const EdgeInsets.symmetric(horizontal: 4),
                       padding: const EdgeInsets.all(4),
                       decoration: BoxDecoration(
                         color: Colors.blue,
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: GestureDetector(
                         onTap: () {},
                         child: const Icon(Icons.search,
                             color: Colors.white, size: 20),
                       ),
                     ),
                   ],
                 ),
               ),
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(30),
               ),
               filled: true,
               fillColor: Colors.grey[100],
             ),
           ),
         ),

         // Toggle Buttons
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           child: Row(
             children: [
               Expanded(
                 child: ElevatedButton(
                   onPressed: () {
                     setState(() {
                       _showOngoing = false;
                     });
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: !_showOngoing
                         ? Colors.teal
                         : Colors.grey[200],
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20),
                     ),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: Text('Completed',
                       style: TextStyle(
                           color: !_showOngoing ? Colors.white : Colors.black)),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: ElevatedButton(
                   onPressed: () {
                     setState(() {
                       _showOngoing = true;
                     });
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: _showOngoing
                         ? Colors.teal
                         : Colors.grey[200],
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(20),
                     ),
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: Text('Ongoing',
                       style: TextStyle(
                           color: _showOngoing ? Colors.white : Colors.black)),
                 ),
               ),
             ],
           ),
         ),

       ],
     ),

   );
  }
}