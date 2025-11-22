import 'dart:developer' as developer;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../data/datasources/printer_local_datasource.dart';
import '../../presentation/setting/models/printer_model.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  final PrinterLocalDatasource _datasource = PrinterLocalDatasource();

  /// Get the default printer or first available printer
  Future<PrinterModel?> getActivePrinter() async {
    final defaultPrinter = await _datasource.getDefaultPrinter();
    if (defaultPrinter != null) return defaultPrinter;

    final printers = await _datasource.getPrinters();
    if (printers.isNotEmpty) return printers.first;

    return null;
  }

  /// Connect to a printer
  Future<bool> connectToPrinter(PrinterModel printer) async {
    if (printer.type != PrinterType.bluetooth) {
      developer.log('Only Bluetooth printers are currently supported');
      return false;
    }

    if (printer.macAddress.isEmpty) {
      developer.log('MAC address is required for Bluetooth printer');
      return false;
    }

    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAddress,
      );
      developer.log('Printer connection result: $result');
      return result;
    } catch (e) {
      developer.log('Error connecting to printer: $e');
      return false;
    }
  }

  /// Ensure printer is connected before printing
  Future<bool> ensureConnected() async {
    // Check if already connected
    final isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      developer.log('Printer already connected');
      return true;
    }

    // Get active printer
    final printer = await getActivePrinter();
    if (printer == null) {
      developer.log('No printer configured');
      return false;
    }

    // Connect to printer
    return await connectToPrinter(printer);
  }

  /// Print bytes with auto-connect
  Future<bool> printBytes(List<int> bytes) async {
    final connected = await ensureConnected();
    if (!connected) {
      developer.log('Failed to connect to printer');
      return false;
    }

    try {
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      developer.log('Print result: $result');
      return result;
    } catch (e) {
      developer.log('Error printing: $e');
      return false;
    }
  }

  /// Disconnect from printer
  Future<bool> disconnect() async {
    try {
      final result = await PrintBluetoothThermal.disconnect;
      developer.log('Disconnect result: $result');
      return result;
    } catch (e) {
      developer.log('Error disconnecting: $e');
      return false;
    }
  }

  /// Check connection status
  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }
}
