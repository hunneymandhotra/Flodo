import 'package:flutter/material.dart';

class SearchHighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;
  final TextStyle? highlightStyle;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    this.baseStyle,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final String loweredText = text.toLowerCase();
    final String loweredQuery = query.toLowerCase();

    final List<TextSpan> spans = [];
    int start = 0;
    int index;

    while ((index = loweredText.indexOf(loweredQuery, start)) != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }

      // Add matching text with highlight
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle ?? const TextStyle(backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
      ));

      start = index + query.length;
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
