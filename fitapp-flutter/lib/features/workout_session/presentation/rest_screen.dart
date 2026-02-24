import 'dart:async';
import 'package:flutter/material.dart';

class RestScreen extends StatefulWidget {
  final int seconds;
  final VoidCallback onFinish;

  const RestScreen({
    super.key,
    required this.seconds,
    required this.onFinish,
  });

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  late int _secondsLeft;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _finish();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;

    _timer?.cancel();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rest')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Rest Time',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              '$_secondsLeft',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _finish,
              child: const Text('Skip Rest'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
