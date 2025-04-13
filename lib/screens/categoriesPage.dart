import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/SpecificCategoryPage.dart';

class Categoriespage extends StatelessWidget {
  const Categoriespage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('All Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [

            _buildRow(context, 'assets/images/cook.png', 'assets/images/02.png',100,'Cooking','Graphic Design'),
            _buildRow(context, 'assets/images/03.png', 'assets/images/04.png',100,'Programming','SEO & Marketing'),
            _buildRow(context, 'assets/images/05.png', 'assets/images/06.png',100,'Finance and Accounting','Personal Development'),
            _buildRow(context, 'assets/images/07.png', 'assets/images/08.png',100,'Office Productivity','Arts & Humanities'),
          ],
        ),
      ),
    );
  }

  
  Widget _buildRow(BuildContext context, String asset1, String asset2,double height, String category1, String category2) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _navigateToNewPage(context,category1);
            },
            child: Image.asset(
              asset1,
              width: 100,
              height: height,
            ),
          ),
          GestureDetector(
            onTap: () {
              _navigateToNewPage(context,category2);
            },
            child: Image.asset(
              asset2,
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  
  void _navigateToNewPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificCategoryPage(category:category,),
      ),
    );
  }
}



