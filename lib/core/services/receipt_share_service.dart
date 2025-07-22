import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';

import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/data/models/receipt_config.dart';
import 'package:vendura/core/services/receipt_generator.dart';

class ReceiptShareService {
  const ReceiptShareService._();

  /// Generates a simple PDF for the receipt and opens the print / share dialog.
  static Future<void> printReceipt(Receipt receipt, {ReceiptConfig? config}) async {
    try {
      final List<int> pdfBytes = await _generateReceiptPdf(receipt, config: config);
      await Printing.sharePdf(bytes: Uint8List.fromList(pdfBytes), filename: '${receipt.id}.pdf');
    } catch (e) {
      rethrow;
    }
  }

  /// Opens the platform email app with the receipt details pre-filled.
  /// Optionally attaches a PDF copy if supported.
  static Future<void> emailReceipt(Receipt receipt, {ReceiptConfig? config}) async {
    final subject = Uri.encodeComponent('Your receipt from Vendura Cafe (#${receipt.id})');
    final bodyText = Uri.encodeComponent(
      ReceiptGenerator.formatReceiptForPrint(receipt, config: config),
    );

    final mailUri = Uri.parse('mailto:?subject=$subject&body=$bodyText');

    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri);
    } else {
      // Fallback: share via share sheet
      await Share.share(Uri.decodeComponent(bodyText));
    }
  }

  /// Helper – generate very simple PDF (monospace text) from receipt.
  static Future<List<int>> _generateReceiptPdf(Receipt receipt, {ReceiptConfig? config}) async {
    final doc = pw.Document();
    final content = ReceiptGenerator.formatReceiptForPrint(receipt, config: config);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Text(content, style: const pw.TextStyle(fontSize: 10));
        },
      ),
    );

    return doc.save();
  }
} 