import 'package:flutter/material.dart';

var stileBottoni = ButtonStyle(
  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF485fa2)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0)
    ),
  ),
);

var coloreAppBar = const Color(0xFF27366f);