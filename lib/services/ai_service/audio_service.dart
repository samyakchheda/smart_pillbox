import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeSpeechRecognition();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
      debugLogging: true, // Enable debug logs
    );

    if (!available) {
      print("Speech recognition not available.");
    } else {
      print("Speech recognition is available.");
    }
  }

  Future<void> startRecording() async {
    if (!_speech.isAvailable || _isListening) return;

    _isListening = true;
    _recognizedText = '';

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            _recognizedText =
                result.recognizedWords; // Update with partial results
            print("Partial recognition: $_recognizedText");
          }

          if (result.finalResult) {
            _isListening = false;
            print("Final recognized text: $_recognizedText");
          }
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true, // Allow capturing partial results
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
    }
  }

  Future<String> stopRecording() async {
    if (!_isListening) return '';

    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }

    // Wait a bit to ensure recognition result is finalized
    await Future.delayed(Duration(milliseconds: 500));

    if (_recognizedText.isEmpty) {
      print('Speech recognition failed.');
      return 'Failed to transcribe speech';
    }

    print('Recognized text: $_recognizedText');
    return _recognizedText;
  }
}
