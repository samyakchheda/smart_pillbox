import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmScreen extends StatefulWidget {
  final String payload;

  const AlarmScreen({Key? key, required this.payload}) : super(key: key);

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableLockScreenVisibility();
  }

  Future<void> _enableLockScreenVisibility() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from dismissing
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Alarm!',
                    style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 20),
                Text('Time to take your medicine!'),
                Text('Details: ${widget.payload}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Dismiss the alarm and close the activity
                    SystemNavigator.pop();
                  },
                  child: Text('Dismiss'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
