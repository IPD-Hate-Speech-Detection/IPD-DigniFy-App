import 'package:dignify/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioDetectionPage extends StatefulWidget {
  @override
  _AudioDetectionPageState createState() => _AudioDetectionPageState();
}

class _AudioDetectionPageState extends State<AudioDetectionPage> {
  String? pickedFileName;
  String? pickedFilePath;
  AudioPlayer audioPlayer = AudioPlayer();
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isPlaying = false;

  Future<void> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        setState(() {
          pickedFileName = result.files.single.name;
          pickedFilePath = result.files.single.path;
        });
        await audioPlayer.setSourceUrl(pickedFilePath!);
        audioPlayer.onDurationChanged.listen((duration) {
          setState(() {
            totalDuration = duration;
          });
        });
        audioPlayer.onPositionChanged.listen((position) {
          setState(() {
            currentDuration = position;
          });
        });
      } else {
        // User canceled the picker
        setState(() {
          pickedFileName = "No file selected";
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        pickedFileName = "Error picking file: $e";
      });
    }
  }

  void togglePlayPause() async {
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
      body: Padding(
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
                onPressed: pickAudioFile,
                child: const Text("Pick Audio"),
              ),
            ),
            const SizedBox(height: 20),
            if (pickedFilePath != null) ...[
              Slider(
                value: currentDuration.inSeconds.toDouble(),
                max: totalDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  seekAudio(Duration(seconds: value.toInt()));
                },
              ),
              Text(
                "${formatDuration(currentDuration)} / ${formatDuration(totalDuration)}",
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: togglePlayPause,
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
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
                onPressed: () {
                  // Add your detection logic here
                },
                child: const Text(
                  "Detect Hate Speech",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
