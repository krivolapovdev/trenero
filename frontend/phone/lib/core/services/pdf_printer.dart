import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

final pdfPrinterProvider = Provider<PdfPrinter>(
  (ref) => const PlatformPdfPrinter(),
);

/// Hands an already built PDF document over to the printing system.
abstract class PdfPrinter {
  /// Opens the platform print dialog for [bytes] under the job name [name].
  ///
  /// Returns `true` when the document was sent to a printer and `false` when
  /// the user cancelled the dialog.
  Future<bool> print({required Uint8List bytes, required String name});
}

/// [PdfPrinter] backed by the print dialog of the `printing` plugin.
class PlatformPdfPrinter implements PdfPrinter {
  const new();

  @override
  Future<bool> print({required Uint8List bytes, required String name}) =>
      Printing.layoutPdf(name: name, onLayout: (format) => bytes);
}
