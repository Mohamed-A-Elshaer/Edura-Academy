import 'package:flutter/material.dart';

String getDiscount(int index) {
  switch (index) {
    case 0:
      return '25% OFF*';
    case 1:
      return '30% OFF*';
    case 2:
      return '15% OFF*';
    default:
      return '';
  }
}

String getTitle(int index) {
  switch (index) {
    case 0:
      return "Today's Special";
    case 1:
      return "Limited Time Offer";
    case 2:
      return "Weekly Deals";
    default:
      return '';
  }
}

String getDescription(int index) {
  switch (index) {
    case 0:
      return 'Get a Discount for Every Course Order only Valid for Today!';
    case 1:
      return 'Exclusive discounts for first-time users. Act fast!';
    case 2:
      return 'Special discounts on trending courses this week!';
    default:
      return '';
  }
}

Color getBackgroundColor(int index) {
  switch (index) {
    case 0:
      return Colors.blue;
    case 1:
      return Colors.green;
    case 2:
      return Colors.purple;
    default:
      return Colors.red;
  }
}
