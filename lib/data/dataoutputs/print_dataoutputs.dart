import 'dart:developer' as developer;
import 'dart:math';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/data/datasources/store_local_datasource.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/core/utils/amount_parser.dart';

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
    int paper, {
    String? operationMode,
  }) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paper == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    bytes += generator.reset();

    // Load logo using assets generator
    try {
      final ByteData data = await rootBundle.load(Assets.logo.xWhite.path);
      final Uint8List bytesData = data.buffer.asUint8List();
      final img.Image? originalImage = img.decodeImage(bytesData);

      if (originalImage != null) {
        developer.log(
            'Logo decoded successfully: ${originalImage.width}x${originalImage.height}',
            name: 'PrintDataoutputs');

        // Resize based on paper size - make it smaller for better compatibility
        // For 58mm paper, max width should be around 384 pixels (48mm * 8 pixels/mm)
        // For 80mm paper, max width should be around 576 pixels (72mm * 8 pixels/mm)
        final int maxWidth = paper == 58 ? 200 : 300;
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: maxWidth,
          maintainAspect: true,
        );
        developer.log(
            'Logo resized to: ${resizedImage.width}x${resizedImage.height}',
            name: 'PrintDataoutputs');

        // Convert to grayscale for thermal printer compatibility
        final img.Image grayscaleImage = img.grayscale(resizedImage);

        // Center the image before printing
        bytes += generator.feed(1);

        // Use imageRaster for logo printing - ensure proper alignment
        bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
        developer.log('Logo added to print bytes', name: 'PrintDataoutputs');

        bytes += generator.feed(2);
      } else {
        developer.log('Logo image is null after decode',
            name: 'PrintDataoutputs');
        print('Logo image is null after decode');
      }
    } catch (e, stackTrace) {
      // If logo fails to load, just continue without it
      developer.log('Failed to load logo: $e\n$stackTrace',
          name: 'PrintDataoutputs');
      print('Failed to load logo: $e');
    }

    // Get store data
    final storeDatasource = StoreLocalDatasource();
    final store = await storeDatasource.getStoreDetail();

    // Store name - adjust size based on paper width
    final storeName = store?.name ?? 'Resto Code With Bahri';
    bytes += generator.text(storeName,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
          width: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
        ));

    // Store address - ensure center alignment (no spacing)
    if (store?.address != null && store!.address!.isNotEmpty) {
      bytes += generator.text(
        store.address!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

    // Store phone - ensure center alignment (no spacing)
    if (store?.phone != null && store!.phone!.isNotEmpty) {
      bytes += generator.text(
        store.phone!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

    // Store email (optional) - ensure center alignment (no spacing)
    if (store?.email != null && store!.email!.isNotEmpty) {
      bytes += generator.text(
        store.email!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

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

    // Operation mode - dynamic based on order
    String operationModeText = 'Dine In';
    if (operationMode != null) {
      final mode = operationMode.toLowerCase().trim();
      if (mode == 'takeaway' || mode == 'takeout') {
        operationModeText = 'Take Away';
      } else if (mode == 'dine_in' || mode == 'dinein') {
        operationModeText = 'Dine In';
      }
    }
    bytes += generator.text(operationModeText,
        styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(
        paper == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    for (final product in products) {
      // Calculate price correctly using AmountParser for robust parsing
      final unitPrice = AmountParser.parse(product.product.price);
      final totalPrice = unitPrice * product.quantity;

      bytes += generator.row([
        PosColumn(
          text: '${product.quantity} x ${product.product.name}',
          width: 8,
          styles: const PosStyles(bold: true, align: PosAlign.left),
        ),
        PosColumn(
          text: totalPrice.currencyFormatRpV2,
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

    // Use subTotal parameter that was passed (already calculated correctly)
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: subTotal.currencyFormatRpV2,
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
        text: pajak.currencyFormatRpV2,
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
        text: serviceCharge.currencyFormatRpV2,
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
        text: totalPrice.currencyFormatRpV2,
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

    // Load logo using assets generator
    try {
      final ByteData data = await rootBundle.load(Assets.logo.xWhite.path);
      final Uint8List bytesData = data.buffer.asUint8List();
      final img.Image? originalImage = img.decodeImage(bytesData);

      if (originalImage != null) {
        // Resize based on paper size
        final int logoWidth = paper == 58 ? 150 : 200; // Smaller for 58mm paper
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: logoWidth,
          maintainAspect: true,
        );

        // Convert to grayscale for thermal printer compatibility
        final img.Image grayscaleImage = img.grayscale(resizedImage);

        // Use imageRaster with proper alignment
        bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
        bytes += generator.feed(2);
      }
    } catch (e) {
      // If logo fails to load, just continue without it
      print('Failed to load logo: $e');
    }

    // Get store data
    final storeDatasource = StoreLocalDatasource();
    final store = await storeDatasource.getStoreDetail();

    // Store name - adjust size based on paper width
    final storeName = store?.name ?? 'Order Checker';
    bytes += generator.text(storeName,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
          width: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
        ));
    bytes += generator.feed(1);
    bytes += generator.text('Table $tableNumber',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
          width: paper == 58 ? PosTextSize.size1 : PosTextSize.size2,
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

  Future<List<int>> printCashSessionReport({
    required CashSessionData session,
    required int paperSize,
  }) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator =
        Generator(paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    bytes += generator.reset();

    // Load logo using assets generator
    try {
      developer.log('Loading logo from: ${Assets.logo.xWhite.path}',
          name: 'PrintDataoutputs');
      final ByteData data = await rootBundle.load(Assets.logo.xWhite.path);
      final Uint8List bytesData = data.buffer.asUint8List();
      developer.log('Logo bytes loaded: ${bytesData.length} bytes',
          name: 'PrintDataoutputs');

      final img.Image? originalImage = img.decodeImage(bytesData);

      if (originalImage != null) {
        developer.log(
            'Logo decoded successfully: ${originalImage.width}x${originalImage.height}',
            name: 'PrintDataoutputs');

        // Resize based on paper size - make it smaller for better compatibility
        final int maxWidth = paperSize == 58 ? 200 : 300;
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: maxWidth,
          maintainAspect: true,
        );
        developer.log(
            'Logo resized to: ${resizedImage.width}x${resizedImage.height}',
            name: 'PrintDataoutputs');

        // Convert to grayscale for thermal printer compatibility
        final img.Image grayscaleImage = img.grayscale(resizedImage);

        // Center the image before printing
        bytes += generator.feed(1);

        // Use imageRaster for logo printing - ensure proper alignment
        bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
        developer.log('Logo added to print bytes', name: 'PrintDataoutputs');

        bytes += generator.feed(2);
      } else {
        developer.log('Logo image is null after decode',
            name: 'PrintDataoutputs');
        print('Logo image is null after decode');
      }
    } catch (e, stackTrace) {
      // If logo fails to load, just continue without it
      developer.log('Failed to load logo: $e\n$stackTrace',
          name: 'PrintDataoutputs');
      print('Failed to load logo: $e');
    }

    // Get store data
    final storeDatasource = StoreLocalDatasource();
    final store = await storeDatasource.getStoreDetail();

    // Store name - adjust size based on paper width - ensure center
    final storeName = store?.name ?? 'LAPORAN KAS HARIAN';
    bytes += generator.text(storeName,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: paperSize == 58 ? PosTextSize.size1 : PosTextSize.size2,
          width: paperSize == 58 ? PosTextSize.size1 : PosTextSize.size2,
        ));

    // Store address - ensure center alignment (no spacing)
    if (store?.address != null && store!.address!.isNotEmpty) {
      bytes += generator.text(
        store.address!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

    // Store phone - ensure center alignment (no spacing)
    if (store?.phone != null && store!.phone!.isNotEmpty) {
      bytes += generator.text(
        store.phone!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

    // Store email (optional) - ensure center alignment (no spacing)
    if (store?.email != null && store!.email!.isNotEmpty) {
      bytes += generator.text(
        store.email!,
        styles: const PosStyles(
          bold: false,
          align: PosAlign.center,
        ),
      );
    }

    bytes += generator.text('LAPORAN KAS HARIAN',
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: paperSize == 58 ? PosTextSize.size1 : PosTextSize.size1,
          width: paperSize == 58 ? PosTextSize.size1 : PosTextSize.size1,
        ));

    bytes += generator.text(
        paperSize == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    // Status
    final statusText = session.status == 'open' ? 'BUKA' : 'TUTUP';
    bytes += generator.row([
      PosColumn(
        text: 'Status',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: statusText,
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    // Dates and Duration
    if (session.openedAt != null) {
      bytes += generator.row([
        PosColumn(
          text: 'Dibuka',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: DateFormat('dd/MM/yyyy HH:mm').format(session.openedAt!),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if (session.closedAt != null) {
      bytes += generator.row([
        PosColumn(
          text: 'Ditutup',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: DateFormat('dd/MM/yyyy HH:mm').format(session.closedAt!),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // Duration (from openedAt to closedAt in hours)
    if (session.openedAt != null && session.closedAt != null) {
      final duration = session.closedAt!.difference(session.openedAt!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      String durationText;
      if (hours > 0) {
        durationText = minutes > 0 ? '$hours jam $minutes menit' : '$hours jam';
      } else {
        durationText = '$minutes menit';
      }

      bytes += generator.row([
        PosColumn(
          text: 'Durasi',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: durationText,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.text(
        paperSize == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    // Summary
    bytes += generator.text('RINGKASAN',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
        text: 'Saldo Awal',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: session.openingBalance.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Penjualan Tunai',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: session.cashSales.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: 'Pengeluaran',
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: session.cashExpenses.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    final expectedBalance =
        session.openingBalance + session.cashSales - session.cashExpenses;
    bytes += generator.row([
      PosColumn(
        text: 'Saldo Ekspektasi',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: expectedBalance.currencyFormatRpV2,
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    if (session.closingBalance != null) {
      bytes += generator.row([
        PosColumn(
          text: 'Saldo Fisik',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: session.closingBalance!.currencyFormatRpV2,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      final variance = session.closingBalance! - expectedBalance;
      if (variance != 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Selisih',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true),
          ),
          PosColumn(
            text: variance.currencyFormatRpV2,
            width: 6,
            styles: PosStyles(
              align: PosAlign.right,
              bold: true,
            ),
          ),
        ]);
      }
    }

    bytes += generator.text(
        paperSize == 80
            ? '------------------------------------------------'
            : '--------------------------------',
        styles: const PosStyles(bold: false, align: PosAlign.center));

    // Expenses
    final expenses = session.expenses ?? [];
    if (expenses.isNotEmpty) {
      bytes += generator.text('PENGELUARAN',
          styles: const PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size1,
          ));

      for (final expense in expenses) {
        bytes += generator.text(expense.description ?? '-',
            styles: const PosStyles(align: PosAlign.left, bold: true));
        if (expense.category != null && expense.category!.isNotEmpty) {
          bytes += generator.text('Kategori: ${expense.category}',
              styles: const PosStyles(align: PosAlign.left));
        }
        bytes += generator.row([
          PosColumn(
            text: expense.createdAt != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(expense.createdAt!)
                : '-',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: expense.amount.currencyFormatRpV2,
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]);
        bytes += generator.feed(1);
      }

      bytes += generator.text(
          paperSize == 80
              ? '------------------------------------------------'
              : '--------------------------------',
          styles: const PosStyles(bold: false, align: PosAlign.center));
    }

    // Notes
    if (session.notes != null && session.notes!.isNotEmpty) {
      bytes += generator.text('CATATAN',
          styles: const PosStyles(
            bold: true,
            align: PosAlign.center,
          ));
      bytes += generator.text(session.notes!,
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          paperSize == 80
              ? '------------------------------------------------'
              : '--------------------------------',
          styles: const PosStyles(bold: false, align: PosAlign.center));
    }

    bytes += generator.text('Terima kasih',
        styles: const PosStyles(bold: false, align: PosAlign.center));
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }
}
