import 'package:flutter/material.dart';

var stileBottoni = ButtonStyle(
  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF485fa2)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0)
    ),
  ),
);

var coloreAppBar = Color(0xFF27366f);