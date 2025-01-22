import 'package:flutter/material.dart';

class Screen2 extends StatelessWidget {
  final List<bool> isChecked;
  final Function(int) onCheckboxChange;
  final PageController pageController;

  const Screen2({super.key,
    required this.isChecked,
    required this.onCheckboxChange,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Frequency',
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
          _buildCheckbox('Morning', 0),
          _buildCheckbox('Afternoon', 1),
          _buildCheckbox('Evening', 2),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 55, 223),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              ElevatedButton(
                onPressed: isChecked.contains(true)
                    ? () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked.contains(true)
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, int index) {
    return GestureDetector(
      onTap: () {
        onCheckboxChange(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isChecked[index]
                ? const Color.fromARGB(255, 58, 55, 223)
                : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isChecked[index]
              ? const Color.fromARGB(50, 58, 55, 223)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked[index],
              onChanged: (value) {
                onCheckboxChange(index);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
