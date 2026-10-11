import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

final pdfPrinterProvider = Provider<PdfPrinter>(
  (ref) => const PlatformPdfPrinter(),
);

/// Hands an already built PDF document over to the printing system.
abstract class PdfPrinter {
  /// Opens the platform print dialog for [bytes] under the job name [name].
  ///
  /// [format] is the paper the document was laid out for: the platform picks
  /// the sheet it offers from it, so an album document handed over with a
  /// portrait format is printed shrunk onto a portrait sheet.
  ///
  /// Returns `true` when the document was sent to a printer and `false` when
  /// the user cancelled the dialog.
  Future<bool> print({
    required Uint8List bytes,
    required String name,
    required PdfPageFormat format,
  });
}

/// [PdfPrinter] backed by the print dialog of the `printing` plugin.
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
