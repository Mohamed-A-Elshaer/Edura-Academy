import 'package:flutter/material.dart';

class CategoryLanguage extends StatefulWidget {
  const CategoryLanguage({
    super.key,
  });

  @override
  State<CategoryLanguage> createState() => _CategoryLanguageState();
}

class _CategoryLanguageState extends State<CategoryLanguage> {
  bool isAchecked = false;
  bool isEchecked = false;
  void ubdate(String lan) {
    setState(() {
      if (lan == 'ar') {
        isAchecked = true;
        isEchecked = false;
      } else if (lan == 'EN') {
        isEchecked = true;
        isAchecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'English (US)',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Checkbox(
              value: isEchecked,
              onChanged: (bool? value) {
                ubdate('EN');
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Arabic',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Checkbox(
              value: isAchecked,
              onChanged: (bool? value) {
                ubdate('ar');
              },
            ),
          ],
        ),
      ],
    );
  }
}
