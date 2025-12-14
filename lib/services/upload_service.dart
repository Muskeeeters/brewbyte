import 'dart:typed_data'; // Bytes handling (Web/Mobile)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  // 1. Pick Image (Returns XFile)
  Future<XFile?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Size compression
    );
    return image;
  }

  // 2. Upload Image (Smart PNG/JPG handling)
  Future<String?> uploadImage(XFile xfile, String bucketName, String folderPath) async {
    try {
      final Uint8List bytes = await xfile.readAsBytes();
      
      // Determine File Extension
      final String fileExt = xfile.name.split('.').last.toLowerCase();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String fullPath = '$folderPath/$fileName';

      // Determine Mime Type
      String mimeType = 'image/jpeg'; // Default
      if (fileExt == 'png') {
        mimeType = 'image/png';
      }

      print("DEBUG: Uploading bytes to $fullPath in bucket '$bucketName'");

      await _supabase.storage.from(bucketName).uploadBinary(
        fullPath,
        bytes,
        fileOptions: FileOptions(
          contentType: mimeType, 
          upsert: true
        ),
      );

      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fullPath);
      print("DEBUG: Upload Success! Link: $publicUrl");
      
      return publicUrl;
    } catch (e) {
      print("DEBUG: Upload Failed Error: $e");
      return null;
    }
  }

  // 3. Delete Old Image (Cleanup)
  Future<void> deleteFile(String bucketName, String folderPath, String imageUrl) async {
    try {
      // URL se filename extract karna
      // URL format: .../image/profiles/12345.jpg
      final Uri uri = Uri.parse(imageUrl);
      final String fileName = uri.pathSegments.last; 
      final String fullPath = '$folderPath/$fileName';

      print("DEBUG: Deleting old file: $fullPath");

      await _supabase.storage.from(bucketName).remove([fullPath]);
    } catch (e) {
      print("Delete Error (Ignored): $e");
    }
  }
}