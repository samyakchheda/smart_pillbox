import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:http/http.dart' as http;

class WiFiScannerScreen extends StatefulWidget {
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
          const SnackBar(
            content:
                Text('Location permission is required to scan Wi-Fi networks.'),
          ),
        );
      }
    } else {
      await _startScan();
    }
  }

  void _startPeriodicScan() {
    // Periodically scan for Wi-Fi networks every 3 seconds
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _startScan();
    });
  }

  Future<void> _startScan() async {
    try {
      // Check if Wi-Fi is enabled
      _isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
      setState(() {}); // Update UI based on Wi-Fi status

      if (!_isWifiEnabled) {
        return;
      }

      // Start the Wi-Fi scan
      await WiFiScan.instance.startScan();
      await _updateWifiList();
    } catch (e) {
      print('Error initiating Wi-Fi scan: $e');
    }
  }

  Future<void> _updateWifiList() async {
    try {
      final scannedResults = await WiFiScan.instance.getScannedResults();

      // Update the Wi-Fi list only if there are changes
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
          title: const Text('Provisioning'),
          content: const Text('Provisioning started. Please wait...'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Stop'),
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
          title: const Text('Device provisioned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Device successfully connected to the ${response.bssid} network'),
              SizedBox.fromSize(size: const Size.fromHeight(20)),
              const Text('Device:'),
              Text('IP: ${response.ipAddressText}'),
              Text('BSSID: ${response.bssidText}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  IconData _getWifiIcon(int level) {
    if (level >= -50) {
      return Icons.wifi; // Excellent signal
    } else if (level >= -70) {
      return Icons.wifi_outlined; // Good signal
    } else if (level >= -85) {
      return Icons.wifi_lock; // Fair signal
    } else {
      return Icons.signal_wifi_off; // Weak signal
    }
  }

  int dBmToPercentage(int dBm) {
    if (dBm <= -100) {
      return 0;
    } else if (dBm >= -50) {
      return 100;
    } else {
      return 2 * (dBm + 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi-Fi Scanner'),
        backgroundColor: const Color(0xFFE0E0E0),
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
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          elevation: 8,
                          child: ListTile(
                            leading: Icon(
                              _getWifiIcon(wifi.level),
                              color: Colors.blue,
                              size: 30,
                            ),
                            title: Text(
                              wifi.ssid,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Signal Strength: ${wifi.level} dBm ($signalPercentage%)'),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => Theme(
                                data: Theme.of(context).copyWith(
                                    dialogBackgroundColor: Colors.white),
                                child: AlertDialog(
                                  title:
                                      Text('Enter Password for ${wifi.ssid}'),
                                  content: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    cursorColor: Colors.black,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Color(0xFF4276FD), // Text color
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
                                      child: const Text('Connect'),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.white, // Text color
                                        backgroundColor: Color(0xFF4276FD),
                                      ),
                                    ),
                                  ],
                                ),
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
                  const Text(
                    'Please enable Wi-Fi to continue',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      WiFiForIoTPlugin.setEnabled(true,
                          shouldOpenSettings: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF4276FD), // Blue background color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15), // Increase size
                      textStyle: const TextStyle(
                        fontSize: 18,
                      ), // Larger text
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                      ),
                    ),
                    child: const Text('Enable Wi-Fi'),
                  ),
                ],
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
