import 'package:flutter/material.dart';
import 'package:sentimentapplication/pages/videocapturing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sentiment Analysis"),
      ),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CaptureVideoPage()),
              );
            },
            child: const Text("Capture Video"),
          ),
        ],
      ),
    );
  }
}
