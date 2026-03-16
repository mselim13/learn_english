import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart' as img;

class CropPhotoPage extends StatefulWidget {
  final String imagePath;

  const CropPhotoPage({super.key, required this.imagePath});

  @override
  State<CropPhotoPage> createState() => _CropPhotoPageState();
}

class _CropPhotoPageState extends State<CropPhotoPage> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();
  bool _isCropping = false;

  Future<void> cropImage() async {
    if (_isCropping) return;
    final state = editorKey.currentState;
    if (state == null) {
      _showError('Düzenleyici hazır değil.');
      return;
    }

    setState(() => _isCropping = true);

    try {
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        _showError('Dosya bulunamadı.');
        return;
      }
      final rawBytes = await file.readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        _showError('Görsel işlenemedi.');
        return;
      }

      final wImg = decoded.width;
      final hImg = decoded.height;

      Rect? rect = state.getCropRect();
      rect ??= state.editAction?.cropRect;

      double left;
      double top;
      double width;
      double height;

      if (rect != null) {
        left = rect.left;
        top = rect.top;
        width = rect.width;
        height = rect.height;
        if (width <= 1 && height <= 1) {
          left = left * wImg;
          top = top * hImg;
          width = width * wImg;
          height = height * hImg;
        }
      } else {
        left = 0;
        top = 0;
        width = wImg.toDouble();
        height = hImg.toDouble();
      }

      final x = left.round().clamp(0, wImg - 1);
      final y = top.round().clamp(0, hImg - 1);
      final w = width.round().clamp(1, wImg - x);
      final h = height.round().clamp(1, hImg - y);

      final croppedImage = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
      final croppedBytes = img.encodeJpg(croppedImage);

      final tempDir = Directory.systemTemp;
      final outputFile = File('${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await outputFile.writeAsBytes(croppedBytes);

      if (!mounted) return;
      Navigator.pop(context, outputFile.path);
    } catch (e, st) {
      debugPrint('Crop hatası: $e\n$st');
      _showError('Kırpma yapılamadı: $e');
    } finally {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Fotoğrafı kırp"),
        backgroundColor: Colors.black,
        actions: [
          if (_isCropping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: cropImage,
            ),
        ],
      ),
      body: Center(
        child: ExtendedImage.file(
          File(widget.imagePath),
          cacheRawData: true,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.editor,
          extendedImageEditorKey: editorKey,
          initEditorConfigHandler: (state) {
            return EditorConfig(
              maxScale: 8.0,
              cropAspectRatio: 1.0,
              cropRectPadding: const EdgeInsets.all(20),
              hitTestSize: 20,
            );
          },
        ),
      ),
    );
  }
}