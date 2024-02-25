// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class CaptureVideoPage extends StatefulWidget {
  const CaptureVideoPage({super.key});

  @override
  _CaptureVideoPageState createState() => _CaptureVideoPageState();
}

class _CaptureVideoPageState extends State<CaptureVideoPage> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool _isRecording = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.isNotEmpty) {
        _controller = CameraController(
            cameras[_selectedCameraIndex], ResolutionPreset.medium);
        _controller.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Capture Video'),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(), // Show a loading indicator while camera initializes
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Video'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isRecording ? stopRecording : startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _toggleCamera,
              child: const Text('Switch Camera'),
            ),
          ),
        ],
      ),
    );
  }

  void startRecording() async {
    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  void stopRecording() async {
    try {
      XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      File sentFile = File(videoFile.path);
      sendVideoFileToServer(sentFile);
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void _toggleCamera() async {
    int newCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    CameraDescription newCamera = cameras[newCameraIndex];
    await _controller.dispose();
    _controller = CameraController(newCamera, ResolutionPreset.medium);
    await _controller.initialize();
    setState(() {
      _selectedCameraIndex = newCameraIndex;
    });
  }

  void sendVideoFileToServer(File videoFile) async {
    var uri = Uri.parse('http://YourIP:5000/upload');

    var request = http.MultipartRequest('POST', uri);

    var videoStream = http.ByteStream(videoFile.openRead());
    var length = await videoFile.length();
    var multipartFile = http.MultipartFile('video', videoStream, length,
        filename: basename(videoFile.path));
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Video file uploaded successfully!');
    } else {
      print('Failed to upload video file. Status code: ${response.statusCode}');
    }
  }
}
