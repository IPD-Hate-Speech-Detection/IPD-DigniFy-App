import 'dart:io';
import 'package:dignify/constants/colors.dart';
import 'package:dignify/services/video_detection_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:dignify/widgets/loading_indicator_widget.dart';

class VideoDetectionPage extends StatefulWidget {
  const VideoDetectionPage({super.key});

  @override
  State<VideoDetectionPage> createState() => _VideoDetectionPageState();
}

class _VideoDetectionPageState extends State<VideoDetectionPage> {
  String? pickedFileName;
  String? pickedFilePath;
  VideoPlayerController? _videoController;
  bool isPlaying = false;
  bool isLoading = false;
  String detectionResult = '';
  double aspectRatio = 13 / 9;

  final VideoHateDetectionService _videoHateDetectionService =
      VideoHateDetectionService();

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> initializeVideo(String filePath) async {
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    _videoController = VideoPlayerController.file(File(filePath));

    try {
      await _videoController!.initialize();
      setState(() {
        aspectRatio = _videoController!.value.aspectRatio;
      });
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      _showErrorDialog("Error initializing video: $e");
    }
  }

  Future<void> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null) {
        setState(() {
          pickedFileName = result.files.single.name;
          pickedFilePath = result.files.single.path;
          detectionResult = '';
          isPlaying = false;
        });

        await initializeVideo(pickedFilePath!);
      } else {
        setState(() {
          pickedFileName = "No file selected";
        });
      }
    } catch (e) {
      print(e.toString());
      _showErrorDialog("Error picking file: $e");
    }
  }

  Future<void> detectHateSpeech() async {
    if (pickedFilePath == null || pickedFilePath!.isEmpty) {
      _showErrorDialog("No video file selected");
      return;
    }

    setState(() {
      isLoading = true;
      detectionResult = '';
    });

    try {
      final decoded =
          await _videoHateDetectionService.uploadVideo(pickedFilePath);

      setState(() {
        if (decoded.containsKey('prediction')) {
          final prediction = decoded['prediction'];

          if (prediction == 'hate') {
            detectionResult = "The video contains hate speech\n";
            if (decoded.containsKey('confidence') &&
                decoded['confidence'] != null) {
              detectionResult +=
                  "Confidence: ${(decoded['confidence'] * 100).toStringAsFixed(2)}%\n";
            }
            if (decoded.containsKey('hate_text') &&
                decoded['hate_text'] != null) {
              detectionResult += "Detected Text: ${decoded['hate_text']}\n";
            }
          } else {
            detectionResult = "No hate speech detected in the video";
          }
        } else {
          detectionResult = "Couldn't analyze the video. Please try again.";
        }
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> togglePlayPause() async {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      isPlaying = _videoController!.value.isPlaying;
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Detection'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Pick a Video to Detect",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                ),
                height: 50,
                width: double.infinity,
                child: pickedFileName != null && pickedFileName!.isNotEmpty
                    ? Center(child: Text(pickedFileName.toString()))
                    : const Center(child: Text("No video picked")),
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape:WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                    backgroundColor:
                       WidgetStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor:
                       WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: isLoading ? null : pickVideoFile,
                  child: const Text("Pick Video"),
                ),
              ),
              const SizedBox(height: 20),
              if (_videoController != null &&
                  _videoController!.value.isInitialized) ...[
                AspectRatio(
                  aspectRatio: aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: togglePlayPause,
                    ),
                    Text(
                      "${formatDuration(_videoController!.value.position)} / ${formatDuration(_videoController!.value.duration)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blueGrey,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context)
                    .size
                    .width, 
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(primaryColor),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: isLoading ? null : detectHateSpeech,
                  child: const Text(
                    "Detect Hate Speech",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const LoadingIndicatorWidget()
              else if (detectionResult.isNotEmpty)
                Text(
                  detectionResult,
                  style: TextStyle(
                    color: detectionResult.contains('contains')
                        ? Colors.red
                        : Colors.green,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
