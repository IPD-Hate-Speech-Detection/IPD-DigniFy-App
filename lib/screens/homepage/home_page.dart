import 'package:dignify/screens/hate_detection/image_detection_page.dart';
import 'package:dignify/screens/hate_detection/text_detection_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Select an Option",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () => Get.to(const TextDetectionPage()),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.3),
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.text_fields,
                          size: 60,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Text Detection",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.amber),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () => Get.to(const ImageDetectionPage()),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.3),
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 60,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Image Detection",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () => _showToast(context, "Coming soon"),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.3),
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 60,
                        ),
                        SizedBox(width: 20),
                        Text(
                          "Video Detection",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.amber),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
