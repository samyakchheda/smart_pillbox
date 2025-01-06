import 'package:flutter/material.dart';

class Screen3 extends StatefulWidget {
  final List<bool> isChecked;
  final Map<int, TimeOfDay?> selectedTimes;
  final Function(int, TimeOfDay) onTimeChange;
  final VoidCallback saveData;

  Screen3({
    required this.isChecked,
    required this.selectedTimes,
    required this.onTimeChange,
    required this.saveData,
  });

  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    // Filter selected indices
    List<int> selectedIndices = widget.isChecked
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Set Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: selectedIndices.length,
              itemBuilder: (context, index) {
                int frequencyIndex = selectedIndices[index];
                String label = [
                  'Morning 🌅',
                  'Afternoon 🌞',
                  'Evening 🌙'
                ][frequencyIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150, // Rectangular box height
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 242, 242, 242),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Hours Picker
                          _buildTimePicker(
                            min: 1,
                            max: 12,
                            initialValue:
                                widget.selectedTimes[frequencyIndex]?.hour == 0
                                    ? 12
                                    : (widget.selectedTimes[frequencyIndex]
                                                ?.hour ??
                                            1) %
                                        12,
                            onChange: (value) {
                              setState(() {
                                int hour = value == 12
                                    ? (widget.selectedTimes[frequencyIndex]
                                                    ?.hour ??
                                                0) >=
                                            12
                                        ? 12
                                        : 0
                                    : value +
                                        ((widget.selectedTimes[frequencyIndex]
                                                        ?.hour ??
                                                    0) >=
                                                12
                                            ? 12
                                            : 0);
                                widget.onTimeChange(
                                    frequencyIndex,
                                    TimeOfDay(
                                        hour: hour,
                                        minute: widget
                                                .selectedTimes[frequencyIndex]
                                                ?.minute ??
                                            0));
                              });
                            },
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          // Minutes Picker
                          _buildTimePicker(
                            min: 0,
                            max: 59,
                            initialValue:
                                widget.selectedTimes[frequencyIndex]?.minute ??
                                    0,
                            onChange: (value) {
                              setState(() {
                                widget.onTimeChange(
                                    frequencyIndex,
                                    TimeOfDay(
                                        hour: widget
                                                .selectedTimes[frequencyIndex]
                                                ?.hour ??
                                            0,
                                        minute: value));
                              });
                            },
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          // AM/PM Picker
                          _buildTimePicker(
                            min: 0,
                            max: 1,
                            initialValue:
                                (widget.selectedTimes[frequencyIndex]?.hour ??
                                            0) >=
                                        12
                                    ? 1
                                    : 0,
                            onChange: (value) {
                              setState(() {
                                int currentHour = widget
                                        .selectedTimes[frequencyIndex]?.hour ??
                                    0;
                                int currentMinute = widget
                                        .selectedTimes[frequencyIndex]
                                        ?.minute ??
                                    0;

                                if (value == 1) {
                                  currentHour = (currentHour % 12) + 12;
                                } else {
                                  currentHour = currentHour % 12;
                                }

                                widget.onTimeChange(
                                    frequencyIndex,
                                    TimeOfDay(
                                        hour: currentHour,
                                        minute: currentMinute));
                              });
                            },
                            labels: ['AM', 'PM'],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: widget.saveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 58, 55, 223),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(16),
            ),
            child: Text(
              'Finish',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Time picker for hour, minute, or AM/PM
  Widget _buildTimePicker({
    required int min,
    required int max,
    required int initialValue,
    required Function(int) onChange,
    List<String>? labels,
  }) {
    return Expanded(
      child: Stack(
        children: [
          // Horizontal line positioned above the selected number
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
              ],
            ),
          ),
          // Horizontal line positioned below the selected number
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
                Expanded(
                  child: Divider(color: Colors.grey, thickness: 1.5),
                ),
              ],
            ),
          ),
          // The list wheel scroll view for selecting values
          ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChange(min + index); // Adjust index to match the display range
            },
            perspective: 0.003,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final currentValue = min + index;
                final isSelected = currentValue == initialValue;

                final textStyle = TextStyle(
                  fontSize: isSelected ? 18 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey,
                );

                if (labels != null) {
                  return Center(
                    child: Text(
                      labels[index],
                      style: textStyle,
                    ),
                  );
                }
                return Center(
                  child: Text(
                    currentValue.toString(),
                    style: textStyle,
                  ),
                );
              },
              childCount: max - min + 1,
            ),
          ),
        ],
      ),
    );
  }
}
