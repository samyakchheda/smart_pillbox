import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home/routes/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:http/http.dart' as http;
import 'package:home/theme/app_colors.dart'; // Assuming this exists

class WiFiScannerScreen extends StatefulWidget {
  const WiFiScannerScreen({super.key});

  @override
  _WiFiScannerScreenState createState() => _WiFiScannerScreenState();
}

class _WiFiScannerScreenState extends State<WiFiScannerScreen> {
  List<WiFiAccessPoint> _wifiList = [];
  Timer? _scanTimer;
  TextEditingController _passwordController = TextEditingController();
  bool _isWifiEnabled = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startPeriodicScan();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      if (await Permission.locationWhenInUse.request().isGranted) {
        await _startScan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission is required to scan Wi-Fi networks.'.tr(),
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
            backgroundColor: AppColors.cardBackground,
          ),
        );
      }
    } else {
      await _startScan();
    }
  }

  void _startPeriodicScan() {
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _startScan();
    });
  }

  Future<void> _startScan() async {
    try {
      _isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
      setState(() {});

      if (!_isWifiEnabled) {
        return;
      }

      await WiFiScan.instance.startScan();
      await _updateWifiList();
    } catch (e) {
      print('Error initiating Wi-Fi scan: $e');
    }
  }

  Future<void> _updateWifiList() async {
    try {
      final scannedResults = await WiFiScan.instance.getScannedResults();

      if (!listEquals(scannedResults, _wifiList)) {
        setState(() {
          _wifiList = scannedResults;
        });
      }
    } catch (e) {
      print('Error retrieving Wi-Fi scan results: $e');
    }
  }

  void _startProvisioning(String ssid, String password) async {
    final provisioner = Provisioner.espTouch();

    provisioner.listen((response) {
      Navigator.of(context).pop(response);
    });

    provisioner.start(ProvisioningRequest.fromStrings(
      ssid: ssid,
      bssid: '00:00:00:00:00:00',
      password: password,
    ));

    ProvisioningResponse? response = await showDialog<ProvisioningResponse>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Provisioning'.tr(),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Provisioning started. Please wait...'.tr(),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.buttonColor,
              ),
              child: Text(
                'Stop'.tr(),
                style: TextStyle(color: AppColors.buttonColor),
              ),
            ),
          ],
        );
      },
    );

    if (provisioner.running) {
      provisioner.stop();
    }

    if (response != null) {
      _onDeviceProvisioned(response);
    }
  }

  void _onDeviceProvisioned(ProvisioningResponse response) {
    sendCredentials(
        response.ipAddressText as String, 'user@example.com', 'userPassword');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Device provisioned'.tr(),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Device successfully connected to the ${response.bssid} network',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              SizedBox.fromSize(size: Size.fromHeight(20)),
              Text(
                'Device:'.tr(),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              Text(
                'IP: ${response.ipAddressText}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'BSSID: ${response.bssidText}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacementNamed(
                    context, Routes.home); // <-- ADD THIS
              },
              child: Text(
                'OK'.tr(),
                style: TextStyle(color: AppColors.buttonColor),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getWifiIcon(int level) {
    if (level >= -50)
      return Icons.wifi;
    else if (level >= -70)
      return Icons.wifi_outlined;
    else if (level >= -85)
      return Icons.wifi_lock;
    else
      return Icons.signal_wifi_off;
  }

  int dBmToPercentage(int dBm) {
    if (dBm <= -100)
      return 0;
    else if (dBm >= -50)
      return 100;
    else
      return 2 * (dBm + 100);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: isDarkMode ? AppColors.kWhiteColor : AppColors.kBlackColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 8,
          shadowColor: AppColors.textSecondary.withOpacity(0.3),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 16,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textPlaceholder),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.buttonColor,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Wi-Fi Scanner'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.home);
              },
              child: Text(
                'Skip'.tr(),
                style: TextStyle(
                  color: AppColors.buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: _isWifiEnabled
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _wifiList.length,
                        itemBuilder: (context, index) {
                          _wifiList.sort((a, b) => b.level.compareTo(a.level));
                          final wifi = _wifiList[index];
                          if (wifi.ssid.isEmpty) return const SizedBox.shrink();
                          final signalPercentage = dBmToPercentage(wifi.level);
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                _getWifiIcon(wifi.level),
                                color: AppColors.buttonColor,
                                size: 30,
                              ),
                              title: Text(
                                wifi.ssid,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              subtitle: Text(
                                'Signal Strength: ${wifi.level} dBm ($signalPercentage%)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppColors.cardBackground,
                                  title: Text(
                                    'Enter Password for ${wifi.ssid}',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                    ),
                                  ),
                                  content: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.borderColor),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.buttonColor),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    cursorColor: AppColors.buttonColor,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel'.tr(),
                                        style: TextStyle(
                                          color: AppColors.buttonColor,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        String password =
                                            _passwordController.text;
                                        Navigator.pop(context);
                                        _startProvisioning(
                                            wifi.ssid ?? '', password);
                                      },
                                      child: Text(
                                        'Connect'.tr(),
                                        style: TextStyle(
                                          color: AppColors.buttonColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please enable Wi-Fi to continue'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        WiFiForIoTPlugin.setEnabled(true,
                            shouldOpenSettings: true);
                      },
                      child: Text('Enable Wi-Fi'.tr()),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void sendCredentials(String esp32Ip, String email, String password) async {
    final url = 'http://your-flask-server-ip:5000/send_credentials';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'esp32_ip': esp32Ip,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('Credentials sent successfully!');
    } else {
      print('Failed to send credentials. Error: ${response.statusCode}');
    }
  }
}
