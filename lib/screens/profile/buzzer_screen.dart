import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class BuzzerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BuzzerScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<BuzzerScreen> createState() => _BuzzerScreenState();
}

class _BuzzerScreenState extends State<BuzzerScreen> {
  String? _selectedTone;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription<void>? _playerCompleteSubscription;

  // Hardcoded ESP32 IP; update or fetch from config as needed
  final String _esp32Ip = "192.168.1.106";

  /// Display name → API sound key
  final Map<String, String> _toneToApi = {
    'Beep Beep': 'beep_beep',
    'Calm Tune': 'calm_tune',
    'Gentle Chime': 'gentle_chime',
    'Soft Melody': 'soft_melody',
    'Relaxing Sound': 'relaxing',
  };

  /// Display name → local asset path
  final Map<String, String> _toneFiles = {
    'Beep Beep': 'assets/buzzer/beep_beep.wav',
    'Calm Tune': 'assets/buzzer/calm_tune.wav',
    'Gentle Chime': 'assets/buzzer/gentle_chime.wav',
    'Soft Melody': 'assets/buzzer/soft_melody.wav',
    'Relaxing Sound': 'assets/buzzer/relaxing_sound.wav',
  };

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Sends the buzzer API request without blocking playback
  Future<void> _sendBuzzerApi(String displayTone) async {
    // 1. Map to API sound key
    final apiSound = _toneToApi[displayTone];
    if (apiSound == null) {
      debugPrint('⚠️ Invalid tone: $displayTone');
      return;
    }

    // 2. Fetch current Firebase user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('⚠️ No Firebase user signed in');
      return;
    }

    // 3. Call Buzzer API
    final uri =
        Uri.parse('https://6617-183-87-183-2.ngrok-free.app/buzzer/play');
    final body = jsonEncode({
      'esp32_ip': _esp32Ip,
      'sound_type': apiSound,
    });

    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (resp.statusCode != 200) {
        debugPrint('⚠️ Buzzer API error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('⚠️ Exception calling buzzer API: $e');
    }
  }

  Future<void> _playPreview(String displayTone) async {
    // 1. Stop existing playback
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    // Fire-and-forget API call
    unawaited(_sendBuzzerApi(displayTone));

    // 2. Play local preview asset immediately
    final rawPath = _toneFiles[displayTone];
    if (rawPath == null) {
      debugPrint('⚠️ No asset file for tone: $displayTone');
      return;
    }
    final playPath = rawPath.replaceFirst('assets/', '');
    await _audioPlayer.play(AssetSource(playPath));

    // 3. Update UI state
    if (mounted) {
      setState(() {
        _selectedTone = displayTone;
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPreview() async {
    await _audioPlayer.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  void _saveBuzzerTone() {
    _stopPreview();
    // Persist _selectedTone as needed
    debugPrint('Selected buzzer tone: $_selectedTone');
    widget.onBack();
  }

  List<Widget> _buildToneOptions() {
    return _toneToApi.keys.map((tone) {
      final isSelected = _selectedTone == tone;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.buttonColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            title: Text(
              tone.tr(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:
                    isSelected ? AppColors.buttonColor : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying && isSelected ? Icons.stop : Icons.play_arrow,
                    color: AppColors.buttonColor,
                  ),
                  onPressed: () {
                    if (_isPlaying && isSelected) {
                      _stopPreview();
                    } else {
                      _playPreview(tone);
                    }
                  },
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.buttonColor),
              ],
            ),
            onTap: () {
              if (_isPlaying && isSelected) {
                _stopPreview();
              } else {
                _playPreview(tone);
              }
            },
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppColors.buttonColor),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  'Buzzer Settings'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Select Buzzer Tone'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildToneOptions(),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _selectedTone != null ? _saveBuzzerTone : null,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                'Save Selection'.tr(),
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
