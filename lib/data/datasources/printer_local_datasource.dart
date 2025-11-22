import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/setting/models/printer_model.dart';

class PrinterLocalDatasource {
  static const String _keySavedPrinters = 'saved_printers';
  static const String _keyDefaultPrinter = 'default_printer';

  /// Save a list of printers
  Future<bool> savePrinters(List<PrinterModel> printers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = printers.map((p) => p.toJson()).toList();
    return prefs.setString(_keySavedPrinters, json.encode(jsonList));
  }

  /// Get all saved printers
  Future<List<PrinterModel>> getPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySavedPrinters);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((json) => PrinterModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new printer
  Future<bool> addPrinter(PrinterModel printer) async {
    final printers = await getPrinters();
    // Check if printer already exists (by MAC address or IP)
    final exists = printers.any((p) =>
        (printer.type == PrinterType.bluetooth &&
            p.macAddress == printer.macAddress) ||
        (printer.type == PrinterType.wifi && p.ipAddress == printer.ipAddress));

    if (!exists) {
      printers.add(printer);
      return savePrinters(printers);
    }
    return false;
  }

  /// Remove a printer
  Future<bool> removePrinter(PrinterModel printer) async {
    final printers = await getPrinters();
    printers.removeWhere((p) =>
        (printer.type == PrinterType.bluetooth &&
            p.macAddress == printer.macAddress) ||
        (printer.type == PrinterType.wifi && p.ipAddress == printer.ipAddress));
    return savePrinters(printers);
  }

  /// Set default printer
  Future<bool> setDefaultPrinter(PrinterModel printer) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyDefaultPrinter, json.encode(printer.toJson()));
  }

  /// Get default printer
  Future<PrinterModel?> getDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyDefaultPrinter);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final jsonData = json.decode(jsonStr);
      return PrinterModel.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Clear all saved printers
  Future<bool> clearPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDefaultPrinter);
    return prefs.remove(_keySavedPrinters);
  }
}
