import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Callback types for parsed text elements
typedef OnUrlTap = void Function(String url);
typedef OnPhoneTap = void Function(String phone);
typedef OnEmailTap = void Function(String email);
typedef OnMentionTap = void Function(String mention);
typedef OnHashtagTap = void Function(String hashtag);

/// Configuration for text parsing with callbacks and styling
class VTextParserConfig {
  /// Called when a URL is tapped
  final OnUrlTap? onUrlTap;
  /// Called when a phone number is tapped
  final OnPhoneTap? onPhoneTap;
  /// Called when an email is tapped
  final OnEmailTap? onEmailTap;
  /// Called when a @mention is tapped
  final OnMentionTap? onMentionTap;
  /// Called when a #hashtag is tapped
  final OnHashtagTap? onHashtagTap;
  /// Style for bold text (**text** or __text__)
  final TextStyle? boldStyle;
  /// Style for italic text (*text* or _text_)
  final TextStyle? italicStyle;
  /// Style for inline code (`code`)
  final TextStyle? codeStyle;
  /// Style for URLs
  final TextStyle? urlStyle;
  /// Style for phone numbers
  final TextStyle? phoneStyle;
  /// Style for emails
  final TextStyle? emailStyle;
  /// Style for @mentions
  final TextStyle? mentionStyle;
  /// Style for #hashtags
  final TextStyle? hashtagStyle;
  const VTextParserConfig({
    this.onUrlTap,
    this.onPhoneTap,
    this.onEmailTap,
    this.onMentionTap,
    this.onHashtagTap,
    this.boldStyle,
    this.italicStyle,
    this.codeStyle,
    this.urlStyle,
    this.phoneStyle,
    this.emailStyle,
    this.mentionStyle,
    this.hashtagStyle,
  });
  /// Creates a copy with modified values
  VTextParserConfig copyWith({
    OnUrlTap? onUrlTap,
    OnPhoneTap? onPhoneTap,
    OnEmailTap? onEmailTap,
    OnMentionTap? onMentionTap,
    OnHashtagTap? onHashtagTap,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? codeStyle,
    TextStyle? urlStyle,
    TextStyle? phoneStyle,
    TextStyle? emailStyle,
    TextStyle? mentionStyle,
    TextStyle? hashtagStyle,
  }) {
    return VTextParserConfig(
      onUrlTap: onUrlTap ?? this.onUrlTap,
      onPhoneTap: onPhoneTap ?? this.onPhoneTap,
      onEmailTap: onEmailTap ?? this.onEmailTap,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      onHashtagTap: onHashtagTap ?? this.onHashtagTap,
      boldStyle: boldStyle ?? this.boldStyle,
      italicStyle: italicStyle ?? this.italicStyle,
      codeStyle: codeStyle ?? this.codeStyle,
      urlStyle: urlStyle ?? this.urlStyle,
      phoneStyle: phoneStyle ?? this.phoneStyle,
      emailStyle: emailStyle ?? this.emailStyle,
      mentionStyle: mentionStyle ?? this.mentionStyle,
      hashtagStyle: hashtagStyle ?? this.hashtagStyle,
    );
  }
}

/// Parsed text element types
enum _ParsedType { text, bold, italic, code, url, phone, email, mention, hashtag, link }

class _ParsedElement {
  final _ParsedType type;
  final String text;
  final String? url; // For link type [text](url)
  _ParsedElement(this.type, this.text, [this.url]);
}

/// Lightweight text parser for story text content
///
/// Parses text and returns [TextSpan] with appropriate styling and tap handlers.
///
/// ## Supported Patterns
/// - **Bold**: `**text**` or `__text__`
/// - **Italic**: `*text*` or `_text_`
/// - **Code**: `` `code` ``
/// - **Links**: `[text](url)`
/// - **URLs**: Auto-detected (http://, https://, www.)
/// - **Phones**: Auto-detected (+1234567890, (123) 456-7890)
/// - **Emails**: Auto-detected (user@example.com)
/// - **Mentions**: `@username`
/// - **Hashtags**: `#tag`
///
/// ## Example
/// ```dart
/// final parser = VTextParser();
/// final span = parser.parse(
///   'Hello **World**! Check @john and #flutter',
///   baseStyle: TextStyle(color: Colors.white),
///   config: VTextParserConfig(
///     onMentionTap: (mention) => print('Tapped: $mention'),
///     onHashtagTap: (tag) => print('Tapped: $tag'),
///   ),
/// );
/// ```
class VTextParser {
  // Pattern order matters - more specific patterns first
  static final _patterns = <_ParsedType, RegExp>{
    // Markdown link [text](url)
    _ParsedType.link: RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
    // Bold **text** or __text__
    _ParsedType.bold: RegExp(r'\*\*(.+?)\*\*|__(.+?)__'),
    // Italic *text* or _text_ (not preceded/followed by same char)
    _ParsedType.italic: RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)'),
    // Inline code `code`
    _ParsedType.code: RegExp(r'`([^`]+)`'),
    // Email (before URL to avoid conflicts)
    _ParsedType.email: RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    // URL (http, https, www)
    _ParsedType.url: RegExp(r'https?://[^\s<>\[\]]+|www\.[^\s<>\[\]]+'),
    // Phone numbers
    _ParsedType.phone: RegExp(r'(?:\+\d{1,3}[-.\s]?)?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{3,4}'),
    // Mention @username
    _ParsedType.mention: RegExp(r'@[\w]+'),
    // Hashtag #tag
    _ParsedType.hashtag: RegExp(r'#[\w]+'),
  };
  /// Parses text and returns a [TextSpan] tree with styling and tap handlers
  TextSpan parse(
    String text, {
    required TextStyle baseStyle,
    VTextParserConfig config = const VTextParserConfig(),
  }) {
    final elements = _parseText(text);
    final spans = elements.map((e) => _buildSpan(e, baseStyle, config)).toList();
    return TextSpan(children: spans, style: baseStyle);
  }
  List<_ParsedElement> _parseText(String text) {
    final elements = <_ParsedElement>[];
    var remaining = text;
    while (remaining.isNotEmpty) {
      _Match? earliestMatch;
      _ParsedType? matchType;
      // Find the earliest match across all patterns
      for (final entry in _patterns.entries) {
        final match = entry.value.firstMatch(remaining);
        if (match != null) {
          if (earliestMatch == null || match.start < earliestMatch.match.start) {
            earliestMatch = _Match(match, entry.key);
            matchType = entry.key;
          }
        }
      }
      if (earliestMatch == null) {
        // No more patterns found - add remaining as plain text
        elements.add(_ParsedElement(_ParsedType.text, remaining));
        break;
      }
      final match = earliestMatch.match;
      // Add text before match
      if (match.start > 0) {
        elements.add(_ParsedElement(_ParsedType.text, remaining.substring(0, match.start)));
      }
      // Add matched element
      final element = _createElementFromMatch(match, matchType!);
      elements.add(element);
      // Continue with remaining text
      remaining = remaining.substring(match.end);
    }
    return elements;
  }
  _ParsedElement _createElementFromMatch(RegExpMatch match, _ParsedType type) {
    switch (type) {
      case _ParsedType.bold:
        // Group 1 for **, group 2 for __
        final content = match.group(1) ?? match.group(2) ?? '';
        return _ParsedElement(_ParsedType.bold, content);
      case _ParsedType.italic:
        // Group 1 for *, group 2 for _
        final content = match.group(1) ?? match.group(2) ?? '';
        return _ParsedElement(_ParsedType.italic, content);
      case _ParsedType.code:
        return _ParsedElement(_ParsedType.code, match.group(1) ?? '');
      case _ParsedType.link:
        final linkText = match.group(1) ?? '';
        final linkUrl = match.group(2) ?? '';
        return _ParsedElement(_ParsedType.link, linkText, linkUrl);
      case _ParsedType.url:
      case _ParsedType.phone:
      case _ParsedType.email:
      case _ParsedType.mention:
      case _ParsedType.hashtag:
        return _ParsedElement(type, match.group(0) ?? '');
      case _ParsedType.text:
        return _ParsedElement(_ParsedType.text, match.group(0) ?? '');
    }
  }
  TextSpan _buildSpan(_ParsedElement element, TextStyle baseStyle, VTextParserConfig config) {
    switch (element.type) {
      case _ParsedType.text:
        return TextSpan(text: element.text);
      case _ParsedType.bold:
        final style = config.boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold);
        return TextSpan(text: element.text, style: style);
      case _ParsedType.italic:
        final style = config.italicStyle ?? baseStyle.copyWith(fontStyle: FontStyle.italic);
        return TextSpan(text: element.text, style: style);
      case _ParsedType.code:
        final style = config.codeStyle ??
            baseStyle.copyWith(
              fontFamily: 'monospace',
              backgroundColor: Colors.black26,
            );
        return TextSpan(text: element.text, style: style);
      case _ParsedType.link:
        final style = config.urlStyle ??
            baseStyle.copyWith(
              color: Colors.lightBlueAccent,
              decoration: TextDecoration.underline,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onUrlTap != null
              ? (TapGestureRecognizer()..onTap = () => config.onUrlTap!(element.url ?? element.text))
              : null,
        );
      case _ParsedType.url:
        final style = config.urlStyle ??
            baseStyle.copyWith(
              color: Colors.lightBlueAccent,
              decoration: TextDecoration.underline,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onUrlTap != null
              ? (TapGestureRecognizer()..onTap = () => config.onUrlTap!(element.text))
              : null,
        );
      case _ParsedType.phone:
        final style = config.phoneStyle ??
            baseStyle.copyWith(
              color: Colors.greenAccent,
              decoration: TextDecoration.underline,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onPhoneTap != null
              ? (TapGestureRecognizer()..onTap = () => config.onPhoneTap!(element.text))
              : null,
        );
      case _ParsedType.email:
        final style = config.emailStyle ??
            baseStyle.copyWith(
              color: Colors.orangeAccent,
              decoration: TextDecoration.underline,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onEmailTap != null
              ? (TapGestureRecognizer()..onTap = () => config.onEmailTap!(element.text))
              : null,
        );
      case _ParsedType.mention:
        final style = config.mentionStyle ??
            baseStyle.copyWith(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.w600,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onMentionTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => config.onMentionTap!(element.text.substring(1)))
              : null,
        );
      case _ParsedType.hashtag:
        final style = config.hashtagStyle ??
            baseStyle.copyWith(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.w600,
            );
        return TextSpan(
          text: element.text,
          style: style,
          recognizer: config.onHashtagTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => config.onHashtagTap!(element.text.substring(1)))
              : null,
        );
    }
  }
}

class _Match {
  final RegExpMatch match;
  final _ParsedType type;
  _Match(this.match, this.type);
}
