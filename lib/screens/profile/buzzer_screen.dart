import 'dart:async'; // Add this import for StreamSubscription
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/theme/app_colors.dart';
import 'package:audioplayers/audioplayers.dart';

class BuzzerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BuzzerScreen({super.key, required this.onBack});

  @override
  State<BuzzerScreen> createState() => _BuzzerScreenState();
}

class _BuzzerScreenState extends State<BuzzerScreen> {
  String? _selectedTone;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription?
      _playerCompleteSubscription; // Add this to manage the listener

  final List<String> _buzzerTones = [
    'Beep Beep'.tr(),
    'Calm Tune'.tr(),
    'Gentle Chime'.tr(),
    'Soft Melody'.tr(),
    'Relaxing Sound'.tr()
  ];

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
    // Set up the listener in initState
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel(); // Cancel the subscription
    _audioPlayer.dispose(); // Dispose of the audio player
    super.dispose();
  }

  Future<void> _playPreview(String tone) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.play(AssetSource(_toneFiles[tone]!.split('assets/')[1]));
    if (mounted) {
      // Check if mounted before calling setState
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stopPreview() async {
    await _audioPlayer.stop();
    if (mounted) {
      // Check if mounted before calling setState
      setState(() => _isPlaying = false);
    }
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
                  "Buzzer Settings".tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Select Buzzer Tone".tr(),
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
              onPressed: _selectedTone != null
                  ? () {
                      _saveBuzzerTone();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Buzzer tone set to $_selectedTone'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                "Save Selection".tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToneOptions() {
    return _buzzerTones.map((tone) {
      final isSelected = _selectedTone == tone;
      return Padding(
        padding: const EdgeInsets.only(
            bottom: 8.0), // Fix typo: 'bottom' instead of 'custom'
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
              tone,
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
                    _isPlaying && _selectedTone == tone
                        ? Icons.stop
                        : Icons.play_arrow,
                    color: AppColors.buttonColor,
                  ),
                  onPressed: () {
                    if (_isPlaying && _selectedTone == tone) {
                      _stopPreview();
                    } else {
                      setState(() => _selectedTone = tone);
                      _playPreview(tone);
                    }
                  },
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.buttonColor),
              ],
            ),
            onTap: () {
              setState(() => _selectedTone = tone);
            },
          ),
        ),
      );
    }).toList();
  }

  void _saveBuzzerTone() {
    _stopPreview(); // Stop any playing preview
    print('Selected buzzer tone: $_selectedTone');
    widget.onBack();
  }
}
