# zj_pos_printer

A Flutter plugin for Android that provides a simple way to interface with ZJ-POS thermal printers via USB.

## Features

- ⚡ **USB Connectivity**: Easy connection with ZJ-6000 and similar thermal printers.
- 🔠 **Custom Formatting**: Support for Bold, Alignment, and Text Sizes.
- 🌍 **International Support**: Support for multiple Code Pages (CP860, CP850, etc.) for correct accents.
- 🛠 **Easy to use**: Clean API with Enums for configuration.

## Getting Started

### Android Setup

Add the following permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.usb.host" />
```
