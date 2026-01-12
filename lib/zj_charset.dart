class ZjCharset {
  final String name;
  final int byte;

  const ZjCharset._(this.name, this.byte);

  static const portuguese = ZjCharset._("CP860", 0x0D);
  static const multilingual = ZjCharset._("CP850", 0x03);
  static const westernEurope = ZjCharset._("Windows-1252", 0x10);
  static const chinese = ZjCharset._("GBK", 0x00);
  static const pc437 = ZjCharset._("CP437", 0x00);
}
