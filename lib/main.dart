import 'package:flutter/material.dart';
import 'package:location_tracking/order_traking_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: OrderTrakingPage(),
    );
  }
}
