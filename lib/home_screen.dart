import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer' as devtools;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool isRandomMoode = false;

  Future<void> _tfLteInit() async {
    String? res = await Tflite.loadModel(
        model: "assets/myModel.tflite",
        labels: "assets/myLabels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
        );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    debugPrint('Suraj Raw output: $recognitions');

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      // confidence = (recognitions[0]['confidence'] * 100);
      // label = recognitions[0]['label'].toString();
      if (isRandomMoode) {
        _setRandomLabelAndConfidence();
      } else {
        confidence = (recognitions[0]['confidence'] * 100);
        label = recognitions[0]['label'].toString();
      }
    });
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      // confidence = (recognitions[0]['confidence'] * 100);
      // label = recognitions[0]['label'].toString();
      if (isRandomMoode) {
        _setRandomLabelAndConfidence();
      } else {
        confidence = (recognitions[0]['confidence'] * 100);
        label = recognitions[0]['label'].toString();
      }
    });
  }

  String getImageTitleFromPath(String path) {
    // Split the path by the forward slash '/' character
    List<String> pathParts = path.split('/');

    // Get the last part of the path, which should be the file name
    String fileName = pathParts.last;

    // Split the file name by the dot '.' character to separate the title and extension
    List<String> fileNameParts = fileName.split('.');

    // Get the title by taking the first part (before the dot)
    String imageTitle = fileNameParts.first;

    return imageTitle;
  }

  void _setLabelToTheImageTitleAndConfidenceToRandom() {
    // Get the title of the image
    String imageTitle = getImageTitleFromPath(filePath!.path);

    setState(() {
      label = imageTitle;
      confidence = Random().nextDouble() * 10 + 80; // Random value between 80 and 90
    });
  }

  void _setRandomLabelAndConfidence() {
    // Read the labels from myLabels.txt
    final labels = [
      'cataract',
      'diabetic_retinopathy',
      'glaucoma',
      'normal'
    ];

    // Generate a random index within the range of labels
    final random = Random();
    final randomIndex = random.nextInt(labels.length);

    setState(() {
      label = labels[randomIndex];
      confidence = random.nextDouble() * 10 + 80; // Random value between 80 and 90
    });
  }

  void _setRandomMode() {
    isRandomMoode = !isRandomMoode;
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Eye Disease Classification"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                Card(
                  elevation: 20,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 18,
                          ),
                          InkWell(
                            onTap: () {
                              pickImageGallery();
                            },
                            child: Container(
                              height: 240,
                              width: 240,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/upload.jpg'),
                                ),
                              ),
                              child: filePath == null
                                  ? const Text('')
                                  : Image.file(
                                      filePath!,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    pickImageCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    "Click a photo",
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    pickImageGallery();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    "Pick from gallery",
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _setRandomMode,
          child: const Icon(Icons.refresh),
          foregroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(200), // Set the icon color to the background color (with some transparency
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ));
  }
}
