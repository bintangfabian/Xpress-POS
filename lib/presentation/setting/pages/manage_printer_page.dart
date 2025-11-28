import 'dart:developer' as developer;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/printer_local_datasource.dart';
import 'package:xpress/core/services/printer_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/constants/colors.dart';
import '../models/printer_model.dart';

class ManagePrinterPage extends StatefulWidget {
  const ManagePrinterPage({super.key});

  @override
  State<ManagePrinterPage> createState() => _ManagePrinterPageState();
}

class _ManagePrinterPageState extends State<ManagePrinterPage> {
  int selectedIndex = 0;
  int? selectedSize;
  // final List<PrinterModel> datas = [
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  //   PrinterModel(
  //     name: 'Galaxy A30',
  //     address: 12324567412,
  //   ),
  // ];

  String macName = '';

  bool connected = false;
  List<BluetoothInfo> items = [];
  List<PrinterModel> savedPrinters = [];
  PrinterModel? defaultPrinter;
  final PrinterLocalDatasource _printerDatasource = PrinterLocalDatasource();
  final PrinterService _printerService = PrinterService();
  final String _selectSize = "2";
  final _txtText = TextEditingController(text: "Hello developer");

  String optionprinttype = "58 mm";
  List<String> options = ["58 mm", "80 mm"];

  void _logDebug(String message) {
    assert(() {
      developer.log(message, name: 'ManagePrinterPage');
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    loadData();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int porcentbatery = 0;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      _logDebug("Platform version: $platformVersion");
      porcentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    _logDebug("Bluetooth enabled: $result");
    _logDebug("Device info: $platformVersion ($porcentbatery% battery)");
  }

  Future<void> getBluetoots() async {
    setState(() {
      items = [];
    });
    var status2 = await Permission.bluetoothScan.status;
    if (status2.isDenied) {
      await Permission.bluetoothScan.request();
    }
    var status = await Permission.bluetoothConnect.status;
    if (status.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    if (listResult.isEmpty) {
      _logDebug(
          "There are no bluetooth devices linked, go to settings and link the printer");
    } else {
      _logDebug("Touch an item in the list to connect");
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac) async {
    setState(() {
      connected = false;
    });
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    _logDebug("State connected $result");
    if (!mounted) return;
    setState(() {
      connected = result;
    });
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
    _logDebug("Status disconnect $status");
  }

  Future<void> printTest() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    //print("connection status: $conexionStatus");
    if (conexionStatus) {
      List<int> ticket = await testTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      _logDebug("Print test result: $result");
    } else {
      //no conectado, reconecte
      _logDebug("No connected device for test print");
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes +=
        generator.text('Code with Bahri', styles: const PosStyles(bold: true));
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.text(
      'FIC Batch 11',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    //bytes += generator.cut();
    return bytes;
  }

  Future<void> printWithoutPackage() async {
    //impresion sin paquete solo de PrintBluetoothTermal
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      String text = "${_txtText.text}\n";
      bool result = await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: int.parse(_selectSize), text: text));
      _logDebug("Status print result: $result");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status cetak: $result')),
      );
    } else {
      //no conectado, reconecte
      _logDebug("No connected device");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perangkat yang terhubung')),
      );
    }
  }

  Future<void> printString() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      String enter = '\n';
      await PrintBluetoothThermal.writeBytes(enter.codeUnits);
      //size of 1-5
      String text = "Hello";
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: text));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "$text size 2"));
      await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 3, text: "$text size 3"));
    } else {
      //desconectado
      _logDebug("Desconectado bluetooth $conexionStatus");
    }
  }

  Future<void> loadData() async {
    final savedSize = await AuthLocalDataSource().getSizeReceipt();
    if (savedSize.isNotEmpty) {
      setState(() {
        selectedSize = int.parse(savedSize);
      });
    }
    await loadSavedPrinters();
  }

  Future<void> loadSavedPrinters() async {
    final printers = await _printerDatasource.getPrinters();
    final defaultPrinter = await _printerDatasource.getDefaultPrinter();
    if (mounted) {
      setState(() {
        savedPrinters = printers;
        this.defaultPrinter = defaultPrinter;
      });
    }
  }

  Future<void> savePrinter(BluetoothInfo bluetoothInfo) async {
    final sizeReceipt = await AuthLocalDataSource().getSizeReceipt();
    final paperSize = sizeReceipt.isNotEmpty ? sizeReceipt : '58';

    final printer = PrinterModel(
      name: bluetoothInfo.name,
      macAddress: bluetoothInfo.macAdress,
      size: paperSize,
      type: PrinterType.bluetooth,
    );

    final success = await _printerDatasource.addPrinter(printer);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer berhasil disimpan'),
            backgroundColor: AppColors.success,
          ),
        );
        await loadSavedPrinters();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer sudah tersimpan sebelumnya'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> setAsDefaultPrinter(PrinterModel printer) async {
    await _printerDatasource.setDefaultPrinter(printer);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Printer default berhasil diatur'),
          backgroundColor: AppColors.success,
        ),
      );
      await loadSavedPrinters();
    }
  }

  Future<void> deletePrinter(PrinterModel printer) async {
    final success = await _printerDatasource.removePrinter(printer);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
        await loadSavedPrinters();
      }
    }
  }

  Future<void> connectToSavedPrinter(PrinterModel printer) async {
    setState(() {
      connected = false;
    });

    final success = await _printerService.connectToPrinter(printer);
    if (mounted) {
      setState(() {
        connected = success;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil terhubung ke printer'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal terhubung ke printer'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ContentTitle('Kelola Printer'),
            const SpaceHeight(24),

            // Deteksi Printer Otomatis
            _section(
              title: 'Deteksi Printer Otomatis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchInput(
                    controller: searchCtrl,
                    hintText: 'Cari nama printer...',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SpaceHeight(12),
                  // List hasil deteksi
                  ...items
                      .where((e) => e.name
                          .toLowerCase()
                          .contains(searchCtrl.text.toLowerCase()))
                      .map((e) => _PrinterDetectCard(
                            name: e.name,
                            subtitle: 'Bluetooth - Ready',
                            status: 'READY',
                            statusColor: AppColors.success,
                            actionLabel: 'Tambah',
                            onAction: () async {
                              await savePrinter(e);
                            },
                          )),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Belum ada perangkat terdeteksi'),
                    ),
                  const SpaceHeight(12),
                  Button.filled(
                    onPressed: () => getBluetoots(),
                    height: 48,
                    label: 'Scan',
                  ),
                ],
              ),
            ),

            const SpaceHeight(16),

            // Printer Tersimpan
            _section(
              title: 'Printer Tersimpan (${savedPrinters.length})',
              child: savedPrinters.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Belum ada printer yang disimpan',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    )
                  : Column(
                      children: [
                        ...savedPrinters.map((printer) {
                          final isDefault = defaultPrinter != null &&
                              ((printer.type == PrinterType.bluetooth &&
                                      defaultPrinter!.macAddress ==
                                          printer.macAddress) ||
                                  (printer.type == PrinterType.wifi &&
                                      defaultPrinter!.ipAddress ==
                                          printer.ipAddress));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SavedPrinterCard(
                              name: printer.name,
                              subtitle:
                                  '${printer.type.value} - ${printer.size} mm',
                              badgeText: isDefault ? 'DEFAULT' : 'STANDBY',
                              badgeColor: isDefault
                                  ? AppColors.success
                                  : AppColors.warning,
                              isDefault: isDefault,
                              onSetDefault: () => setAsDefaultPrinter(printer),
                              onConnect: () => connectToSavedPrinter(printer),
                              onDelete: () => deletePrinter(printer),
                            ),
                          );
                        }),
                      ],
                    ),
            ),

            const SpaceHeight(16),

            // Pengaturan umum
            _section(
              title: 'Pengaturan umum',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Printer Default'),
                  const SpaceHeight(8),
                  SearchInput(
                    controller: TextEditingController(),
                    hintText: 'Cari printer tersimpan...',
                  ),
                  const SpaceHeight(16),
                  const Text('Ukuran Kertas Struk'),
                  const SpaceHeight(8),
                  Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: const Text('58 mm'),
                        selected: selectedSize == 58,
                        onSelected: (selected) {
                          setState(() =>
                              selectedSize = selected ? 58 : selectedSize);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('80 mm'),
                        selected: selectedSize == 80,
                        onSelected: (selected) {
                          setState(() =>
                              selectedSize = selected ? 80 : selectedSize);
                        },
                      ),
                    ],
                  ),
                  const SpaceHeight(16),
                  Row(
                    children: [
                      Expanded(
                        child: Button.outlined(
                          onPressed: () {
                            setState(() => selectedSize = 80);
                          },
                          height: 48,
                          color: AppColors.white,
                          borderColor: AppColors.grey,
                          textColor: AppColors.black,
                          label: 'Reset ke Default',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Button.filled(
                          onPressed: () async {
                            if (selectedSize != null) {
                              await AuthLocalDataSource()
                                  .saveSizeReceipt('$selectedSize');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Pengaturan disimpan')),
                              );
                            }
                          },
                          height: 48,
                          label: 'Simpan Pengaturan',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _section({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.08 * 255).round()),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _PrinterDetectCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String actionLabel;
  final VoidCallback onAction;
  const _PrinterDetectCard({
    required this.name,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Button.filled(
              onPressed: onAction,
              height: 40,
              label: actionLabel,
            ),
          )
        ],
      ),
    );
  }
}

class _SavedPrinterCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final bool isDefault;
  final VoidCallback onConnect;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;
  const _SavedPrinterCard({
    required this.name,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    this.isDefault = false,
    required this.onConnect,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                  color: badgeColor, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          if (!isDefault && onSetDefault != null)
            Flexible(
              child: Button.outlined(
                onPressed: onSetDefault!,
                height: 40,
                color: AppColors.white,
                borderColor: AppColors.grey,
                textColor: AppColors.black,
                label: 'Set Default',
              ),
            ),
          if (!isDefault && onSetDefault != null) const SizedBox(width: 8),
          Flexible(
            child: Button.filled(
              onPressed: onConnect,
              height: 40,
              label: 'Connect',
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Button.filled(
              onPressed: onDelete,
              height: 40,
              color: AppColors.danger,
              label: 'Hapus',
            ),
          ),
        ],
      ),
    );
  }
}
