import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generatePdf(Map<String, dynamic> policy, String ownerName,
      String vehicleNumber) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text("Insurance Policy"),
            pw.Text("Owner Name: $ownerName"),
            pw.Text("Vehicle Number: $vehicleNumber"),
            pw.Text("Policy Name: ${policy['name']}"),
            pw.Text("Policy Price: ₹${policy['price']}"),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/policy.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
