import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String> downloadFile(String url, String fileName) async {
  try {
    // Get the device's temp directory
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';

    // Download the file
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Write the bytes to a local file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Failed to download file');
    }
  } catch (e) {
    rethrow;
  }
}
