import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextRs extends StatefulWidget {
  const TextRs({super.key});

  @override
  State<TextRs> createState() => _TextRsState();
}

class _TextRsState extends State<TextRs> {
  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();

  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });

      performTextRecognition();
    }
  }

  performTextRecognition() async {
    setState(() {
      scanning = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImage!.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        mytext = recognizedText.text;
        scanning = false;
      });

      textRecognizer.close();

    } catch (e) {
      print('Error during text recognition: $e');
      setState(() {
        scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition App'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          pickedImage == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: ClayContainer(
                    height: 400,
                    child: Center(
                      child: Text('No Image Selected'),
                    ),
                  ),
                )
              : Center(
                  child: Image.file(
                    File(pickedImage!.path),
                    height: 400,
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                label: const Text('Gallery'),
                icon: const Icon(Icons.photo),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                label: const Text('Camera'),
                icon: const Icon(Icons.camera_alt),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Recognized Text:')),
          const SizedBox(height: 30),
          scanning
              ? const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: Colors.black,
                    ),
                  ),
                )
              : Center(
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        mytext,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
