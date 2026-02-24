import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../progress_tracking/domain/workout_set.dart';
import 'rest_screen.dart';
import 'session_summary_screen.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<String> exercises;
  final int startIndex;

  const WorkoutSessionScreen({
    super.key,
    required this.exercises,
    this.startIndex = 0,
  });

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  Timer? _timer;
  bool _isRunning = false;

  int _exerciseSeconds = 0;
  int _sessionSeconds = 0;
  late int _currentIndex;

  static const _restSeconds = 60;

  final List<WorkoutSet> _sets = [];
  final Map<String, List<WorkoutSet>> _sessionSets = {};
  final Map<String, int> _exerciseDurations = {};

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  bool _restFinished = false;

  // -------------------------
  // VIDEO PLAYER
  // -------------------------
  VideoPlayerController? _videoController;

  final Map<String, String> _exerciseVideos = {
    "Bench Press": "assets/videos/bench_press.mp4",
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;

    _startTimer();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final name = widget.exercises[_currentIndex];
    final path = _exerciseVideos[name];

    if (path == null) return;

    _videoController = VideoPlayerController.asset(path);

    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.setVolume(0);
    _videoController!.play();

    if (mounted) setState(() {});
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }

  // -----------------------------
  // TIMER CONTROLS
  // -----------------------------
  void _startTimer() {
    if (_isRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _exerciseSeconds++;
        _sessionSeconds++; // <-- session timer continues global
      });
    });

    setState(() => _isRunning = true);
    _videoController?.play();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    _videoController?.pause();
  }

  // -----------------------------
  // LOCAL SAVE / LOAD
  // -----------------------------
  Future<double?> _getLastWeight(String exercise) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('last_weight_$exercise');
  }

  Future<void> _saveLastWeight(String exercise, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_weight_$exercise', weight);
  }

  // -----------------------------
  // SAVE EXERCISE DATA
  // -----------------------------
  void _saveCurrentExercise() {
    final name = widget.exercises[_currentIndex];

    if (_sets.isNotEmpty) {
      _sessionSets[name] = List.from(_sets);
    }

    _exerciseDurations[name] = _exerciseSeconds;
  }

  // -----------------------------
  // NEXT EXERCISE
  // -----------------------------
  void _nextExercise() {
    _timer?.cancel();
    _disposeVideo();
    _saveCurrentExercise();

    final isLast = _currentIndex == widget.exercises.length - 1;

    if (isLast) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionSummaryScreen(
            sessionSets: _sessionSets,
            sessionSeconds: _sessionSeconds,
            exerciseDurations: _exerciseDurations,
          ),
        ),
      );
      return;
    }

    _restFinished = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestScreen(
          seconds: _restSeconds,

          onFinish: () {
            if (_restFinished || !mounted) return;
            _restFinished = true;

            Navigator.pop(context);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.microtask(() {
                if (!mounted) return;

                // 🚀 أهم خطوة: ضمان إن التايمر يشتغل من جديد
                _isRunning = false;

                setState(() {
                  _currentIndex++;
                  _exerciseSeconds = 0;
                  _sets.clear();
                });

                _startTimer();
                _loadVideo();
              });
            });

          },
        ),
      ),
    );
  }

  // -----------------------------
  // ADD SET DIALOG
  // -----------------------------
  Future<void> _showAddSetDialog() async {
    _repsController.clear();

    final exerciseName = widget.exercises[_currentIndex];
    final lastWeight = await _getLastWeight(exerciseName);

    _weightController.text = lastWeight?.toString() ?? '';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
              ),
            ),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(_weightController.text);
              final reps = int.tryParse(_repsController.text);

              if (weight != null && reps != null && reps > 0) {
                setState(() {
                  _sets.add(WorkoutSet(weight: weight, reps: reps));
                });

                await _saveLastWeight(exerciseName, weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // UTIL
  // -----------------------------
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final exerciseName = widget.exercises[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.black12,
                alignment: Alignment.center,
                child: const Text("No Video Available"),
              ),

            const SizedBox(height: 20),

            Text(
              _formatTime(_exerciseSeconds),
              style: const TextStyle(fontSize: 48),
            ),

            const SizedBox(height: 6),

            Text(
              'Session: ${_formatTime(_sessionSeconds)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              child: Text(_isRunning ? 'Pause' : 'Resume'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _showAddSetDialog,
              child: const Text('Add Set'),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _sets.length,
                itemBuilder: (_, i) {
                  final s = _sets[i];
                  return ListTile(
                    title: Text('${s.weight} kg × ${s.reps}'),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: _nextExercise,
              child: const Text('Next Exercise'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeVideo();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}