import 'dart:io';

import 'package:xpress/core/extensions/date_time_ext.dart';
import 'package:flutter/services.dart';

import 'package:xpress/core/utils/helper_pdf_service.dart';
import 'package:xpress/data/models/response/order_remote_datasource.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class TransactionSalesInvoice {
  static late Font ttf;
  static Future<File> generate(
      List<ItemOrder> itemOrders, String searchDateFormatted) async {
    final pdf = Document();
    // var data = await rootBundle.load("assets/fonts/noto-sans.ttf");
    // ttf = Font.ttf(data);
    final ByteData dataImage = await rootBundle.load('assets/images/logo.png');
    final Uint8List bytes = dataImage.buffer.asUint8List();

    // Membuat objek Image dari gambar
    final image = pw.MemoryImage(bytes);

    pdf.addPage(
      MultiPage(
        build: (context) => [
          buildHeader(image, searchDateFormatted),
          SizedBox(height: 1 * PdfPageFormat.cm),
          buildInvoice(itemOrders),
          Divider(),
          SizedBox(height: 0.25 * PdfPageFormat.cm),
        ],
        footer: (context) => buildFooter(),
      ),
    );

    return HelperPdfService.saveDocument(
        name:
            'Resto Code With Bahri | Transaction Sales Report | ${DateTime.now().millisecondsSinceEpoch}.pdf',
        pdf: pdf);
  }

  static Widget buildHeader(MemoryImage image, String searchDateFormatted) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1 * PdfPageFormat.cm),
            Text('Resto Code With Bahri | Transaction Sales Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 0.2 * PdfPageFormat.cm),
            Text(
              "Data: $searchDateFormatted",
            ),
            Text(
              'Created At: ${DateTime.now().toFormattedDate3()}',
            ),
          ],
        ),
        Image(
          image,
          width: 80.0,
          height: 80.0,
          fit: BoxFit.fill,
        ),
      ]);

  static Widget buildInvoice(List<ItemOrder> itemOrders) {
    final headers = [
      'Total',
      'Sub Total',
      'Tax',
      'Discount',
      'Service',
      'Time'
    ];
    final data = itemOrders.map((item) {
      return [
        _formatCurrency(item.totalAmount ?? '0'),
        _formatCurrency(item.subtotal ?? '0'),
        _formatCurrency(item.taxAmount ?? '0'),
        _formatCurrency(item.discountAmount ?? '0'),
        _formatCurrency(item.serviceCharge ?? '0'),
        item.createdAt?.toFormattedDate2() ?? 'N/A',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(
          fontWeight: FontWeight.bold, color: PdfColor.fromHex('FFFFFF')),
      headerDecoration: BoxDecoration(color: PdfColors.blue),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.center,
        1: Alignment.center,
        2: Alignment.center,
        3: Alignment.center,
        4: Alignment.center,
        5: Alignment.center,
      },
    );
  }

  static Widget buildFooter() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(
              title: 'Address',
              value:
                  'Jalan Melati No. 12, Mranggen, Demak, Central Java, 89568'),
          SizedBox(height: 1 * PdfPageFormat.mm),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static String _formatCurrency(String amount) {
    try {
      final value = double.tryParse(amount) ?? 0.0;
      return NumberFormat('#,###').format(value.toInt());
    } catch (e) {
      return '0';
    }
  }
}
