import 'package:flutter/material.dart';
import 'package:image_white_bg_remover/remove_bg_page.dart';

void main() {
  runApp(const ImageBGRemover());
}

class ImageBGRemover extends StatelessWidget {
  const ImageBGRemover({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WhiteBGRemover(
        imagePath: "assets/car001.jpg",
      ),
    );
  }
}
