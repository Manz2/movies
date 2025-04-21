import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final double fontSize;

  const ExpandableText({super.key, required this.text, this.fontSize = 14});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final maxLines = isExpanded ? null : 5;

    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: maxLines,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: widget.fontSize),
          ),
          if (_needsTruncation())
            Text(
              isExpanded ? 'Weniger anzeigen' : 'Mehr...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  bool _needsTruncation() {
    return widget.text.length > 300; // Schätzung
  }
}
