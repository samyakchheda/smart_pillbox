import 'package:flutter/material.dart';

class Screen1 extends StatelessWidget {
  final PageController pageController;
  final Function(String) onNameChange;
  final String medicineName;

  const Screen1({super.key,
    required this.pageController,
    required this.onNameChange,
    required this.medicineName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Medicine',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => onNameChange(value),
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: medicineName.isNotEmpty
                  ? () {
                      FocusScope.of(context).unfocus();
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: medicineName.isNotEmpty
                    ? const Color.fromARGB(255, 58, 55, 223)
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
