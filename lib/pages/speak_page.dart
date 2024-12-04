import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import '../service/audiorecorderservice.dart';
import 'package:wave/config.dart'; // Add this import for CustomConfig

class AudioRecorderScreen extends StatefulWidget {
  final int userId; // Added userId to the widget

  const AudioRecorderScreen({super.key, required this.userId});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isUploading = false;

  @override
  void dispose() {
    _audioService
        .dispose(); // Ensure resources are released when the screen is disposed
    super.dispose();
  }

  // Method to start recording
  void _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _handleError("Erro ao iniciar a gravação: $e");
    }
  }

  // Method to stop recording
  void _stopRecording() async {
    try {
      final path = await _audioService.stopRecording();
      if (path != null) {
        setState(() {
          _recordingPath = path;
          _isRecording = false;
        });
      }
    } catch (e) {
      _handleError("Erro ao parar a gravação: $e");
    }
  }

  // Method to upload the recording
  void _uploadRecording() async {
    if (_recordingPath == null) {
      _handleError("Nenhum arquivo para enviar.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final apiUrl =
          "https://microservices-to-do-list.onrender.com/api/${widget.userId}/task/speech/recognize"; // Use userId in the URL
      final response =
          await _audioService.sendAudioToApi(_recordingPath!, apiUrl);
      _showMessage("Áudio enviado com sucesso: $response");
    } catch (e) {
      _handleError("Erro ao enviar áudio: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to show a message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Method to handle errors and display error messages
  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }

  // Widget to build the record button
  Widget _buildRecordButton() {
    return ElevatedButton(
      onPressed: _isRecording ? _stopRecording : _startRecording,
      child: Text(_isRecording ? 'Parar Gravação' : 'Iniciar Gravação'),
    );
  }

  // Widget to build the upload button
  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadRecording,
      child: _isUploading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Enviar Gravação'),
    );
  }

  // Widget to display the path of the saved recording
  Widget _buildRecordingPathDisplay() {
    return _recordingPath != null
        ? Text(
            'Gravação salva em: ${_recordingPath!.split('/').last}',
            textAlign: TextAlign.center,
          )
        : const SizedBox.shrink(); // If there's no recording path, show nothing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gravador de Áudio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRecordButton(),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: _isRecording
                  ? WaveWidget(
                      size: Size(300, 100),
                      // Add customization options for the wave visualization
                      config: CustomConfig(
                        gradients: [
                          [Colors.blue, Colors.blue.shade200],
                          [Colors.blue.shade200, Colors.blue.shade400],
                        ],
                        durations: [35000, 19440],
                        heightPercentages: [0.20, 0.23],
                        blur: MaskFilter.blur(BlurStyle.solid, 10),
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                    )
                  : Container(),
            ),
            const SizedBox(height: 16),
            _recordingPath != null
                ? Text('Gravação salva em: ${_recordingPath!.split('/').last}')
                : SizedBox.shrink(),
            _buildUploadButton(), // Assuming you have an upload button implemented
          ],
        ),
      ),
    );
  }
}
