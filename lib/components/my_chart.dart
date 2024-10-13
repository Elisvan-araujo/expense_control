import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  final double value;
  final String label;
  final bool valueOpen;

  const MyChart({
    super.key,
    required this.value,
    required this.label,
    required this.valueOpen,
  });

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(
            value: widget.value,
            backgroundColor: widget.valueOpen
                ? Theme.of(context).colorScheme.tertiary
                : Colors.red.shade100,
            strokeWidth: 15,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.green,
            ),
          ),
        ),
        Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 19,
              color: widget.valueOpen
                  ? Theme.of(context).colorScheme.primary
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
