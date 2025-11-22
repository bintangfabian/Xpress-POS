import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../components/buttons.dart';
import '../services/printer_service.dart';

enum PrintStatus {
  idle,
  printing,
  success,
  error,
  noPrinter,
}

class PrintButton extends StatefulWidget {
  final String label;
  final Future<List<int>> Function() onPrint;
  final Color? color;
  final Widget? icon;
  final double? width;
  final double? height;

  const PrintButton({
    super.key,
    required this.label,
    required this.onPrint,
    this.color,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<PrintButton> createState() => _PrintButtonState();
}

class _PrintButtonState extends State<PrintButton> {
  PrintStatus _status = PrintStatus.idle;
  String? _errorMessage;

  Future<void> _handlePrint() async {
    if (_status == PrintStatus.printing) return;

    setState(() {
      _status = PrintStatus.printing;
      _errorMessage = null;
    });

    try {
      final printerService = PrinterService();

      // Check if printer is available
      final printer = await printerService.getActivePrinter();
      if (printer == null) {
        setState(() {
          _status = PrintStatus.noPrinter;
          _errorMessage =
              'Tidak ada printer yang dikonfigurasi. Silakan tambahkan printer terlebih dahulu.';
        });
        _showMessage(_errorMessage!, AppColors.warning);
        return;
      }

      // Check connection
      final isConnected = await printerService.isConnected();
      if (!isConnected) {
        // Try to connect
        final connected = await printerService.connectToPrinter(printer);
        if (!connected) {
          setState(() {
            _status = PrintStatus.noPrinter;
            _errorMessage =
                'Gagal terhubung ke printer. Pastikan printer dalam jangkauan dan sudah dipasangkan.';
          });
          _showMessage(_errorMessage!, AppColors.danger);
          return;
        }
      }

      // Generate print data
      final printData = await widget.onPrint();

      // Print
      final success = await printerService.printBytes(printData);

      if (success) {
        setState(() {
          _status = PrintStatus.success;
        });
        _showMessage('Struk berhasil dicetak', AppColors.success);
      } else {
        setState(() {
          _status = PrintStatus.error;
          _errorMessage =
              'Gagal mencetak struk. Pastikan printer terhubung dan siap digunakan.';
        });
        _showMessage(_errorMessage!, AppColors.danger);
      }
    } catch (e) {
      setState(() {
        _status = PrintStatus.error;
        _errorMessage = 'Error: $e';
      });
      _showMessage(_errorMessage!, AppColors.danger);
    } finally {
      // Reset to idle after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _status = PrintStatus.idle;
          });
        }
      });
    }
  }

  void _showMessage(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _status == PrintStatus.printing;
    final isDisabled = _status == PrintStatus.printing;

    String buttonLabel = widget.label;
    Widget? buttonIcon = widget.icon;

    if (isLoading) {
      buttonLabel = 'Mencetak...';
      buttonIcon = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (_status == PrintStatus.success) {
      buttonLabel = 'Berhasil!';
      buttonIcon =
          const Icon(Icons.check_circle, size: 16, color: Colors.white);
    } else if (_status == PrintStatus.error ||
        _status == PrintStatus.noPrinter) {
      buttonLabel = 'Coba Lagi';
      buttonIcon =
          const Icon(Icons.error_outline, size: 16, color: Colors.white);
    }

    return Button.filled(
      onPressed: isDisabled ? () {} : _handlePrint,
      label: buttonLabel,
      icon: buttonIcon,
      color: _getButtonColor(),
      disabled: isDisabled,
      width: widget.width ?? double.infinity,
      height: widget.height ?? 50.0,
    );
  }

  Color _getButtonColor() {
    switch (_status) {
      case PrintStatus.printing:
        return AppColors.primary;
      case PrintStatus.success:
        return AppColors.success;
      case PrintStatus.error:
      case PrintStatus.noPrinter:
        return AppColors.danger;
      case PrintStatus.idle:
        return widget.color ?? AppColors.primary;
    }
  }
}
