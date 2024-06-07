import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_white_bg_remover/custom_text_button.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class WhiteBGRemover extends StatefulWidget {
  final String imagePath;
  const WhiteBGRemover({super.key, required this.imagePath});

  @override
  State<WhiteBGRemover> createState() => _WhiteBGRemoverState();
}

class _WhiteBGRemoverState extends State<WhiteBGRemover> {
  File? imageFile;
  @override
  void initState() {
    super.initState();
    assignFile();
  }

  @override
  Widget build(BuildContext context) {
    Size scrSize = MediaQuery.of(context).size;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instruction"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: scrSize.height - statusBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 400,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 10,
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.2),
                    )
                  ],
                ),
                child: imageFile != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.file(imageFile!),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(
                height: 30,
                width: 350,
                child: Text(
                  "Draw Using Camera",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
                width: 350,
                child: Text(
                  "You can use a tripod or books stacked together to hold your phone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              CustomTextButton(
                text: "Remove BG",
                color: Colors.amber,
                textColor: Colors.white,
                width: 200,
                height: 50,
                onTap: () async {
                  var permission = await Permission.storage.request();
                  if (context.mounted && permission.isGranted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          "Remove BG",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: const Text(
                          "Do you want to remove the Background?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          CustomTextButton(
                            text: "Yes, Remove",
                            width: 130,
                            height: 50,
                            onTap: () async {
                              await makeTransparentBackground(imageFile!)
                                  .then((value) {
                                setState(() {
                                  imageFile = value;
                                });
                                print(imageFile!.path);
                              });
                            },
                          ),
                          CustomTextButton(
                            text: "No, Thanks!",
                            width: 130,
                            height: 50,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(width: scrSize.width),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void assignFile() async {
    imageFile = await assetToImage(widget.imagePath).whenComplete(() {
      setState(() {});
    });
  }

  Future<File> assetToImage(String path) async {
    Directory temp = await getTemporaryDirectory();
    final byteData = await rootBundle.load(path);

    final file = File('${temp.path}/${path.split("/").last}');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> makeTransparentBackground(File imageFile) async {
    img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
    String filename = imageFile.path.split("/").last.split(".").first;

    // Uint8List pixels = image.getBytes();
    // for (int i = 0, len = pixels.length; i < len; i += 4) {
    //   if (pixels[i] == 255 && pixels[i + 1] == 255 && pixels[i + 2] == 255) {
    //     pixels[i + 3] = 0;
    //   }
    // }

    int color = img.rgbaToUint32(255, 255, 255, 255);
    int transparent = img.rgbaToUint32(255, 255, 255, 0);
    img.Color trans = img.ColorUint32(transparent);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixelColor = img.rgbaToUint32(
          (image.getPixel(x, y)).r.toInt(),
          (image.getPixel(x, y)).g.toInt(),
          (image.getPixel(x, y)).b.toInt(),
          255,
        );
        if (pixelColor == color) {
          // image.setPixelRgba(x, y, 0, 0, 0, 0);
          image.setPixel(x, y, trans);
        }
      }
    }

    Directory temp = await getTemporaryDirectory();

    return File('${temp.path}/$filename-noBG.png')
      ..writeAsBytesSync(img.encodePng(image));
  }
}
