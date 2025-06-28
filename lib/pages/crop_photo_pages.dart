import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

class CropImagePage extends StatefulWidget {
  final File imageFile;

  const CropImagePage({super.key, required this.imageFile});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _controller = CropController();
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    widget.imageFile.readAsBytes().then((bytes) {
      setState(() {
        _imageData = bytes;
      });
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Crop Image',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xfff8c9d3),
      ),
      body: _imageData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Crop(
                    controller: _controller,
                    image: _imageData!,
                    onCropped: (Uint8List croppedBytes) async {
                      final tempDir = await getTemporaryDirectory();
                      final file = File('${tempDir.path}/cropped.jpg');
                      await file.writeAsBytes(croppedBytes, flush: true);

                      final fileSize = await file.length();
                      if (fileSize > 10 * 1024 * 1024) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Maximum file size is 10MB'),
                            ),
                          );
                        }
                        return;
                      }

                      final mimeType =
                          lookupMimeType(file.path) ?? 'image/jpeg';
                      if (!mimeType.startsWith('image/')) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tipe file tidak valid: $mimeType'),
                            ),
                          );
                        }
                        return;
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context, file);
                      }
                    },
                    aspectRatio: 1,
                    withCircleUi: false,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withOpacity(0.5),
                    cornerDotBuilder: (size, index) => const DotControl(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 22),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLoadingDialog();
                      _controller.crop();
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
