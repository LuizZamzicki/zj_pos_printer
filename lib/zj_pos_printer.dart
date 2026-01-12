import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:zj_pos_printer/zj_charset.dart';

/// Enum to define the text alignment on the printer.
enum ZjAlignment {
  left, // 0
  center, // 1
  right, // 2
}

/// Enum to define the text size.
enum ZjTextSize {
  normal, // 0
  large, // 1
  extraLarge, // 2
}

class ZjPosPrinter {
  static const MethodChannel _channel = MethodChannel('zj_pos_printer');

  /// Starts the connection process with the printer.
  /// This may trigger a USB permission dialog.
  static Future<void> connect() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('connect');
  }

  /// Prints text with formatting options.
  ///
  /// [text] The string to be printed.
  /// [bold] Whether to print in bold.
  /// [size] The font size using [ZjTextSize] enum.
  /// [align] The text alignment using [ZjAlignment] enum.
  static Future<void> printText(
    String text, {
    bool bold = false,
    ZjTextSize size = ZjTextSize.normal,
    ZjAlignment align = ZjAlignment.left,
    ZjCharset charset = ZjCharset.portuguese,
  }) async {
    if (!Platform.isAndroid) return;

    await _channel.invokeMethod('printText', {
      'text': text,
      'bold': bold,
      'size': size.index,
      'align': align.index,
      'charsetName': charset.name,
      'codePageByte': charset.byte,
    });
  }
}
