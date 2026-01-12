import 'package:flutter/material.dart';
import 'dart:async';
import 'package:zj_pos_printer/zj_pos_printer.dart';

void main() {
  runApp(const ZjPosPrinterExample());
}

class ZjPosPrinterExample extends StatefulWidget {
  const ZjPosPrinterExample({super.key});

  @override
  State<ZjPosPrinterExample> createState() => _ZjPosPrinterExampleState();
}

class _ZjPosPrinterExampleState extends State<ZjPosPrinterExample> {
  bool _isConnected = false;

  /// Function to handle printer connection
  Future<void> _connect() async {
    try {
      await ZjPosPrinter.connect();
      // We wait a bit for the OS to handle the USB permission dialog
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isConnected = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection command sent!")),
        );
      }
    } catch (e) {
      debugPrint("Error connecting: $e");
    }
  }

  /// Function to print a complete sample receipt
  Future<void> _printSample() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please connect first!")));
      return;
    }

    try {
      // Header - Large and Bold
      await ZjPosPrinter.printText(
        "ZJ-6000 TEST SHOP\n",
        bold: true,
        size: ZjTextSize.large,
        align: ZjAlignment.center,
      );

      // Subtitle - Normal Center
      await ZjPosPrinter.printText(
        "USB Thermal Printer Plugin\n",
        align: ZjAlignment.center,
      );

      await ZjPosPrinter.printText("------------------------------\n");

      // Items list
      await ZjPosPrinter.printText("1x Burger .......... \$ 15.00\n");
      await ZjPosPrinter.printText(
        "1x Soda ............ \$  5.00\n",
        bold: true,
      );

      await ZjPosPrinter.printText("------------------------------\n");

      // Total - Extra Large
      await ZjPosPrinter.printText(
        "TOTAL: \$ 20.00\n",
        size: ZjTextSize.extraLarge,
        align: ZjAlignment.right,
      );

      // Footer with special characters
      await ZjPosPrinter.printText(
        "Obrigado pela atenção!\nPromoção de Verão 2026\n\n\n",
        align: ZjAlignment.center,
      );
    } catch (e) {
      debugPrint("Error printing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ZJ POS Printer Demo'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.usb, size: 50, color: Colors.blue),
                      const SizedBox(height: 10),
                      Text(
                        _isConnected
                            ? "Printer Connected"
                            : "Printer Disconnected",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.link),
                label: const Text("CONNECT PRINTER"),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _isConnected ? _printSample : null,
                icon: const Icon(Icons.print),
                label: const Text("PRINT TEST RECEIPT"),
              ),
              const Spacer(),
              const Text(
                "Note: Make sure your printer is connected via OTG and powered on.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
