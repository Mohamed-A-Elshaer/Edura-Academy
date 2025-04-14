import 'package:flutter/cupertino.dart';

import 'CustomFilterCheckBox.dart';

class CustomFilterModel extends StatelessWidget{
double? containerHeight;
  String title;
  int itemCount;
  List<String> checkBoxItem;
final List<String> selectedItems;
final Function(String) onToggle;
   CustomFilterModel({super.key,required this.title,required this.itemCount,required this.checkBoxItem,this.containerHeight,required this.selectedItems,
     required this.onToggle,});



  @override
  Widget build(BuildContext context) {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(title,style: TextStyle(fontFamily: 'Jost',fontSize: 18,fontWeight: FontWeight.w600,color: Color(0xff202244)),),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Container(
          height: containerHeight??260,
          child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final item = checkBoxItem[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: CustomFilterCheckBox(
                  text: item,
                  isSelected: selectedItems.contains(item),
                  onChanged: (bool value) {
                    onToggle(item);
                  },
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
  }



}