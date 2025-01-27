import 'package:dignify/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:dignify/widgets/loading_indicator_widget.dart';

class AudioDetectionPage extends StatefulWidget {
  const AudioDetectionPage({super.key});

  @override
  State<AudioDetectionPage> createState() => _AudioDetectionPageState();
}

class _AudioDetectionPageState extends State<AudioDetectionPage> {
  String? pickedFileName;
  String? pickedFilePath;
  AudioPlayer audioPlayer = AudioPlayer();
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;
  bool isLoading = false;
  String detectionResult = '';
  final String apiUrl =
      'https://ipd-image-render-deploy.onrender.com/predict-audio';

  @override
  void initState() {
    super.initState();
    setupAudioPlayer();
  }

  void setupAudioPlayer() {
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        if (position <= totalDuration) {
          currentDuration = position;
        } else {
          currentDuration = totalDuration;
        }
      });
    });

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        currentDuration = totalDuration;
        isPlaying = false;
      });
    });
  }

  Future<void> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        setState(() {
          pickedFileName = result.files.single.name;
          pickedFilePath = result.files.single.path;
          detectionResult = '';
          currentDuration = Duration.zero;
          totalDuration = Duration.zero;
          isPlaying = false;
        });

        await audioPlayer.setSourceUrl(pickedFilePath!);
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
      _showErrorDialog("No audio file selected");
      return;
    }

    setState(() {
      isLoading = true;
      detectionResult = '';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.headers.addAll({
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        pickedFilePath!,
        contentType: MediaType('audio', 'mpeg'),
      ));

      print("Uploading audio...");
      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        print("Response: $result");

        var decoded = jsonDecode(result);

        setState(() {
          if (decoded.containsKey('prediction')) {
            final prediction = decoded['prediction'];
            if (prediction == 'hate') {
              detectionResult = "The audio contains hate speech\n";
              if (decoded.containsKey('confidence')) {
                detectionResult +=
                    "Confidence: ${(decoded['confidence'] * 100).toStringAsFixed(2)}%\n";
              }
              if (decoded.containsKey('text')) {
                detectionResult += "Detected Text: ${decoded['text']}\n";
              }
            } else {
              detectionResult = "No hate speech detected in the audio";
            }
          } else {
            detectionResult = "Couldn't analyze the audio. Please try again.";
          }
        });
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _getSliderValue() {
    if (currentDuration.inSeconds.toDouble() >
        totalDuration.inSeconds.toDouble()) {
      return totalDuration.inSeconds.toDouble();
    }
    if (currentDuration.inSeconds.toDouble() < 0) {
      return 0.0;
    }
    return currentDuration.inSeconds.toDouble();
  }

  double _getSliderMaxValue() {
    return totalDuration.inSeconds.toDouble() > 0
        ? totalDuration.inSeconds.toDouble()
        : 1.0;
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void seekAudio(Duration position) {
    audioPlayer.seek(position);
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Detection'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Pick an Audio to Detect",
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
                    : const Center(child: Text("No audio picked")),
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueGrey),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: isLoading ? null : pickAudioFile,
                  child: const Text("Pick Audio"),
                ),
              ),
              const SizedBox(height: 20),
              if (pickedFilePath != null) ...[
                Slider(
                  value: _getSliderValue(),
                  min: 0.0,
                  max: _getSliderMaxValue(),
                  onChanged: (value) {
                    if (value <= totalDuration.inSeconds.toDouble()) {
                      seekAudio(Duration(seconds: value.toInt()));
                    }
                  },
                ),
                Text(
                  "${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}",
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed:
                      totalDuration.inSeconds > 0 ? togglePlayPause : null,
                  color: Colors.white,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(primaryColor),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: isLoading ? null : detectHateSpeech,
                child: const Text(
                  "Detect Hate Speech",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
