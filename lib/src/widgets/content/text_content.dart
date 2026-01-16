import 'package:flutter/material.dart';
import '../../models/v_story_item.dart';
import '../../utils/text_parser.dart';

/// Widget for displaying text stories with auto-fit text and optional parsing
class TextContent extends StatefulWidget {
  final VTextStory story;
  final VoidCallback onLoaded;
  const TextContent({
    super.key,
    required this.story,
    required this.onLoaded,
  });
  @override
  State<TextContent> createState() => _TextContentState();
}

class _TextContentState extends State<TextContent> {
  final _parser = VTextParser();
  @override
  void initState() {
    super.initState();
    // Text content is instantly ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.story.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildAutoFitText(),
        ),
      ),
    );
  }

  Widget _buildAutoFitText() {
    final story = widget.story;
    // Priority: textBuilder > richText > parsed text > plain text
    if (story.textBuilder != null) {
      return story.textBuilder!(context, story.text);
    }
    final defaultStyle = story.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
        );
    final maxWidth = MediaQuery.of(context).size.width - 64;
    if (story.richText != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text.rich(
            story.richText!,
            style: defaultStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // Use parser when enabled
    if (story.enableParsing) {
      final parsedSpan = _parser.parse(
        story.text,
        baseStyle: defaultStyle,
        config: story.parserConfig ?? const VTextParserConfig(),
      );
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text.rich(
            parsedSpan,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // Plain text fallback
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          story.text,
          style: defaultStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
