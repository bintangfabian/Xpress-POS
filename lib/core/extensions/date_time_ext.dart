import 'package:xpress/core/utils/timezone_helper.dart';

const List<String> _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember'
];

const List<String> _monthNamesShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agt',
  'Sep',
  'Okt',
  'Nov',
  'Des'
];

extension DateTimeExt on DateTime {
  String toFormattedTime() {
    final wib = TimezoneHelper.toWib(this);
    final int hour12 = wib.hour % 12;
    final String monthName = _monthNames[wib.month - 1];

    return '${wib.day} $monthName, ${hour12.toString().padLeft(2, '0')}:${wib.minute.toString().padLeft(2, '0')}';
  }

  String toFormattedDate() {
    final wib = TimezoneHelper.toWib(this);
    String dayName = _dayNames[wib.weekday - 1];
    String day = wib.day.toString();
    String month = _monthNames[wib.month - 1];
    String year = wib.year.toString();

    return '$dayName, $day $month $year';
  }

  String toFormattedDate2() {
    final wib = TimezoneHelper.toWib(this);
    String day = wib.day.toString();
    String month = _monthNames[wib.month - 1];
    String year = wib.year.toString();

    return '$day $month $year';
  }

  String toFormattedDate3() {
    final wib = TimezoneHelper.toWib(this);
    String day = wib.day.toString();
    String month = _monthNames[wib.month - 1];
    String year = wib.year.toString();
    String hour = wib.hour.toString().padLeft(2, '0');
    String minute = wib.minute.toString().padLeft(2, '0');
    String second = wib.second.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute:$second';
  }

  String toFormattedDateShort() {
    final wib = TimezoneHelper.toWib(this);
    String day = wib.day.toString().padLeft(2, '0');
    String month = _monthNamesShort[wib.month - 1];
    String year = wib.year.toString();

    return '$day $month $year';
  }
}
