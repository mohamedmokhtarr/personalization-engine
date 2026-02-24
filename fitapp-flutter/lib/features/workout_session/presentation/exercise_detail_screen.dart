import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../workout_library/domain/exercise.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late VideoPlayerController _controller;
  bool isInit = false;
  bool hasVideo = false;

  @override
  void initState() {
    super.initState();

    // Check if video exists
    hasVideo = widget.exercise.videoAsset.isNotEmpty;

    if (hasVideo) {
      _controller = VideoPlayerController.asset(widget.exercise.videoAsset)
        ..initialize().then((_) {
          _controller.setVolume(0); // MUTE
          _controller.setLooping(true); // LOOP
          setState(() {
            isInit = true;
          });
        });
    }
  }

  @override
  void dispose() {
    if (hasVideo) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================
            // 🎥 EXERCISE VIDEO
            // ======================
            if (hasVideo)
              SizedBox(
                height: 220,
                width: double.infinity,
                child: isInit
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
                    : const Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("No Video Available"),
              ),

            const SizedBox(height: 20),

            // ======================
            // 🏋️ EXERCISE NAME
            // ======================
            Text(
              widget.exercise.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ======================
            // 📄 DESCRIPTION
            // ======================
            Text(
              widget.exercise.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // ======================
            // 🚀 START BUTTON
            // ======================
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: () {
                Navigator.pop(context, "start");
              },
              child: const Text(
                "Start Exercise",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),

      // ======================
      // ▶️ FLOATING BUTTON
      // ======================
      floatingActionButton: hasVideo
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}