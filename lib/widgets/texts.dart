import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget detailText(
  String type,
  String? detail,
) {
  return Text(
    type + ": " + (detail == null ? "No data" : detail).toString(),
    style: TextStyle(
      fontSize: 18,
      color: Colors.black,
      decoration: TextDecoration.none,
    ),
  ).paddingOnly(top: 10);
}

Widget TitleText(
  String text,
) {
  return Text(
    text.toString(),
    style: TextStyle(
        fontSize: 25,
        color: Colors.black,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.bold),
  );
}
