import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

final pdfPrinterProvider = Provider<PdfPrinter>(
  (ref) => const PlatformPdfPrinter(),
);

abstract class PdfPrinter {
  Future<bool> print({
    required Uint8List bytes,
    required String name,
    required PdfPageFormat format,
  });
}

class PlatformPdfPrinter implements PdfPrinter {
  const new();

  @override
  Future<bool> print({
    required Uint8List bytes,
    required String name,
    required PdfPageFormat format,
  }) => Printing.layoutPdf(
    name: name,
    format: format,
    onLayout: (sheet) => bytes,
  );
}
