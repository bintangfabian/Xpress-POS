import 'dart:math';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:xpress/core/utils/timezone_helper.dart';

class PrintDataoutputs {
  PrintDataoutputs._init();

  static final PrintDataoutputs instance = PrintDataoutputs._init();

  Future<List<int>> printOrder(
      List<ProductQuantity> products,
      int totalQuantity,
      int totalPrice,
      String paymentMethod,
      int nominalBayar,
      String namaKasir,
      int discount,
      int tax,
      int subTotal,
      int normalPrice,
      int sizeReceipt) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(sizeReceipt == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    final pajak = totalPrice * 0.11;
    final total = totalPrice + pajak;

    bytes += generator.reset();
    bytes += generator.text('Resto Code With Bahri',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.text('Jalan Nanasa No. 1',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(
        'Date : ${DateFormat('dd/MM/yyyy HH:mm').format(TimezoneHelper.now())}',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(1);
    bytes += generator.text('Pesanan:',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    for (final product in products) {
      bytes += generator.text(product.product.name!,
          styles: const PosStyles(align: PosAlign.left));

      bytes += generator.row([
        PosColumn(
          text:
              '${product.product.price!.toIntegerFromText.currencyFormatRp} x ${product.quantity}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${product.product.price!.toIntegerFromText * product.quantity}'
              .toIntegerFromText
              .currencyFormatRp,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(
        text: 'Normal price',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: normalPrice.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Diskon',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: discount.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Sub total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: subTotal.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pajak PB1 (10%)',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: tax.ceil().currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Final total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: totalPrice.currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Bayar',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: total.ceil().currencyFormatRp,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pembayaran',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: paymentMethod,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('Terima kasih',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);

    return bytes;
  }

  Future<List<int>> printOrderV2(
      List<ProductQuantity> products, int orderId, int paper
      // OrderModel order,
      // Uint8List logo,
      // StoreModel store,
      // TemplateReceiptModel? template,
      ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paper == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    // final ByteData data = await rootBundle.load('assets/logo/mylogo.png');
    // final Uint8List bytesData = data.buffer.asUint8List();
    // final img.Image? orginalImage = img.decodeImage(logo);

    bytes += generator.reset();

    // if (orginalImage != null) {
    //   final img.Image grayscalledImage = img.grayscale(orginalImage);
    //   final img.Image resizedImage =
    //       img.copyResize(grayscalledImage, width: 240);
    //   bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
    //   bytes += generator.feed(3);
    // }

    bytes += generator.text('Resto Code With Bahri',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.text('Jalan Nanasa No. 1',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    // bytes += generator.text('Kab. Sleman, DI Yogyakarta',
    //     styles: const PosStyles(bold: false, align: PosAlign.center));
    // bytes += generator.text('coffeewithbahri@gmail.com',
    //     styles: const PosStyles(bold: false, align: PosAlign.center));
    // bytes += generator.text('085640899224',
    //     styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(1);

    bytes += generator.text(
        paper == 80
            ? '================================================'
            : '================================',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    // if (template.receiptType == 'Default') {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: 'Antrian',
    //       width: 5,
    //       styles: const PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(
    //       text: ':',
    //       width: 1,
    //       styles: const PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(
    //       text: order.noQueue.toString(),
    //       width: 6,
    //       styles: const PosStyles(align: PosAlign.left),
    //     ),
    //   ]);
    // }
    bytes += generator.row([
      PosColumn(
        text: 'ID Transaksi',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: orderId.toString(),
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Waktu',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: DateFormat('dd MMM yy HH:mm').format(TimezoneHelper.now()),
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Order By',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Sarah',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Kasir',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: ':',
        width: 1,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Susan',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    for (final product in products) {
      bytes += generator.row([
        PosColumn(
          text: '${product.quantity} ${product.product.name}',
          width: 8,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: (product.product.price!.toIntegerFromText * product.quantity)
              .currencyFormatRp,
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Subtotal  Produk',
    //     width: 8,
    //     styles: const PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: order.subTotal.currencyFormatRpV2,
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Diskon',
    //     width: 8,
    //     styles: const PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: order.discountAmount.currencyFormatRpV2,
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'PPN',
    //     width: 8,
    //     styles: const PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: order.tax.currencyFormatRpV2,
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Service',
    //     width: 8,
    //     styles: const PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: order.serviceCharge.currencyFormatRpV2,
    //     width: 4,
    //     styles: const PosStyles(align: PosAlign.right),
    //   ),
    // ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Tagihan',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: (products[0].product.price!.toIntegerFromText *
                products[0].quantity)
            .currencyFormatRp,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.row([
      PosColumn(
        text: 'Metode Pembayaran',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Tunai',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Total Bayar',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: (products[0].product.price!.toIntegerFromText *
                products[0].quantity)
            .currencyFormatRp,
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Kembalian',
        width: 8,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Rp 0',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '================================================'
            : '================================',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    // bytes += generator.text('Password: fic11jilid2',
    //     styles: const PosStyles(bold: false, align: PosAlign.center));
    // bytes += generator.feed(1);
    // bytes += generator.text('instagram: @codewithbahri',
    //     styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.text(
        'Terbayar: ${DateFormat('dd-MM-yyyy HH:mm').format(TimezoneHelper.now())}',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.text('dicetak oleh: Susan',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.text('Terima kasih',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> printOrderV3(
    List<ProductQuantity> products,
    int totalQuantity,
    int totalPrice,
    String paymentMethod,
    int nominalBayar,
    int kembalian,
    int subTotal,
    int discount,
    int pajak,
    int serviceCharge,
    String namaKasir,
    String customerName,
    int paper,
  ) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paper == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/logo/mylogo.png');
    final Uint8List bytesData = data.buffer.asUint8List();
    final img.Image? orginalImage = img.decodeImage(bytesData);
    bytes += generator.reset();

    if (orginalImage != null) {
      final img.Image grayscalledImage = img.grayscale(orginalImage);
      final img.Image resizedImage =
          img.copyResize(grayscalledImage, width: 240);
      bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
      bytes += generator.feed(3);
    }

    bytes += generator.text('Resto Code With Bahri',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    bytes += generator.text('Jl. Kebun Raya No. 1, Sinduhadi, Ngaglik',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.text('Kab. Sleman, DI Yogyakarta',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.text('085640899224',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.row([
      PosColumn(
        text: DateFormat('dd MMM yyyy').format(TimezoneHelper.now()),
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: DateFormat('HH:mm').format(TimezoneHelper.now()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Receipt Number',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'JF-${DateFormat('yyyyMMddhhmm').format(TimezoneHelper.now())}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Order ID',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: Random().nextInt(100000).toString(),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Bill Name',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: customerName,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Collected By',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: namaKasir,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.text('Dine In',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    for (final product in products) {
      bytes += generator.row([
        PosColumn(
          text: '${product.quantity} x ${product.product.name}',
          width: 8,
          styles: const PosStyles(bold: true, align: PosAlign.left),
        ),
        PosColumn(
          text: '${product.product.price!.toIntegerFromText * product.quantity}'
              .currencyFormatRpV2,
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    final subTotalPrice = products.fold<int>(
        0,
        (previousValue, element) =>
            previousValue +
            (element.product.price!.toIntegerFromText * element.quantity));
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal $totalQuantity Product',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: subTotalPrice.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Discount',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: discount.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Tax PB1 (10%)',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '${(totalPrice * 0.1).ceil()}'.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Service Charge(5%)',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '${(totalPrice * 0.05).ceil()}'.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(bold: true, align: PosAlign.left),
      ),
      PosColumn(
        text: '$totalPrice'.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Cash',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: nominalBayar.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Return',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: kembalian.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.left));
    bytes += generator.text('Notes',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.text('Pass Wifi: fic14jilid2',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    //terima kasih
    bytes += generator.text('Terima Kasih',
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.feed(3);
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> printQRIS(
      int totalPrice, Uint8List imageQris, int paper) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paper == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    final img.Image? orginalImage = img.decodeImage(imageQris);
    bytes += generator.reset();

    // final Uint8List bytesData = data.buffer.asUint8List();
    // final img.Image? orginalImage = img.decodeImage(bytesData);
    // bytes += generator.reset();

    bytes += generator.text('Scan QRIS Below for Payment',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(2);
    if (orginalImage != null) {
      final img.Image grayscalledImage = img.grayscale(orginalImage);
      final img.Image resizedImage =
          img.copyResize(grayscalledImage, width: 240);
      bytes += generator.imageRaster(resizedImage, align: PosAlign.center);
      bytes += generator.feed(1);
    }

    bytes += generator.text('Price : ${totalPrice.currencyFormatRp}',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    bytes += generator.feed(4);
    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> printChecker(List<ProductQuantity> products,
      int tableNumber, String draftName, String cashierName, int paper) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paper == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    bytes += generator.reset();

    bytes += generator.text('Order Checker',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.feed(1);
    bytes += generator.text(tableNumber.toString(),
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(
        text: 'Date',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: DateFormat('dd-MM-yyyy HH:mm').format(TimezoneHelper.now()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    // bytes += generator.text(
    //     'Date: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
    //     styles: const PosStyles(bold: false, align: PosAlign.left));
    //reciept number
    bytes += generator.row([
      PosColumn(
        text: 'Receipt',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'JF-${DateFormat('yyyyMMddhhmm').format(TimezoneHelper.now())}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    // bytes += generator.text(
    //     'Receipt: JF-${DateFormat('yyyyMMddhhmm').format(DateTime.now())}',
    //     styles: const PosStyles(bold: false, align: PosAlign.left));
//cashier name
    bytes += generator.row([
      PosColumn(
        text: 'Cashier',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: cashierName,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    // bytes += generator.text('Cashier: $cashierName',
    //     styles: const PosStyles(bold: false, align: PosAlign.left));
    //customer name
    //column 2
    bytes += generator.row([
      PosColumn(
        text: 'Customer - $draftName',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'DINE IN',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    //----
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(1);
    for (final product in products) {
      bytes += generator.text('${product.quantity} x  ${product.product.name}',
          styles: const PosStyles(
            align: PosAlign.left,
            bold: false,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          ));
    }

    bytes += generator.feed(1);
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);
    //cut
    bytes += generator.cut();

    return bytes;
  }
}
