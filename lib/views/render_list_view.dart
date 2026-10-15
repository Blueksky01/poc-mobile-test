import 'package:flutter/material.dart';

class RenderListView extends StatefulWidget {
  const new({super.key});

  @override
  State<RenderListView> createState() => _RenderListViewState();
}

class _RenderListViewState extends State<RenderListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Render list')
      ),
    );
  }
}