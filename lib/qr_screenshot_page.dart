import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const QrCodeApp());
}

class QrCodeApp extends StatelessWidget {
  const QrCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Screenshot Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QrCodeScreen(),
    );
  }
}

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  // A GlobalKey to identify the widget boundary for the screenshot
  final GlobalKey _qrCodeKey = GlobalKey();
  final String qrData = "https://flutter.dev";
  bool _isSaving = false;

  // --- Core Logic: Capture and Save Image ---
  Future<void> _captureAndSavePng() async {
    setState(() {
      _isSaving = true; // Show loading indicator
    });

    try {
      // 1. Find the widget boundary
      RenderRepaintBoundary? boundary =
      _qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception("Could not find RepaintBoundary.");
      }

      // 2. Convert the widget to an image
      // Use a high pixelRatio for a sharp image
      ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception("Failed to convert image to bytes.");
      }

      // 3. Save the image to the device gallery
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        name: "qrcode_${DateTime.now().millisecondsSinceEpoch}",
      );

      // 4. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['isSuccess']
              ? 'QR Code Saved to Gallery! 🥳'
              : 'Failed to Save QR Code. 😢'),
          backgroundColor: result['isSuccess'] ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print("Error in capture and save: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while saving.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom QR Code Screenshot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // --- WIDGET TO BE CAPTURED ---
            // RepaintBoundary identifies the section to screenshot.
            // The widget inside this boundary will be captured.
            RepaintBoundary(
              key: _qrCodeKey,
              child: Container(
                width: 300,
                height: 300,
                // CUSTOM BACKGROUND: This Container applies the background
                // and padding for the final screenshot image.
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 5),
                  // App Icon as Background - make sure the path is correct
                  image: const DecorationImage(
                    image: AssetImage('assets/app_icon_bg.png'),
                    fit: BoxFit.cover,
                    opacity: 0.2, // Make it subtle
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                      // The QR code color should contrast well with the background
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      // Optional: Embed a small image in the center of the QR
                      embeddedImage: const AssetImage('assets/app_icon_bg.png'),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // -----------------------------

            const SizedBox(height: 40),

            // --- WIDGET TO BE EXCLUDED (THE BUTTON) ---
            // This button is OUTSIDE the RepaintBoundary and will not be in the screenshot.
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _captureAndSavePng,
              icon: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Screenshot'),
            ),
            // ------------------------------------------
          ],
        ),
      ),
    );
  }
}