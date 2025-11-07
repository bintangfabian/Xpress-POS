import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';

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
  'Desember',
];

String _formatDisplayDate(DateTime date) {
  final monthName = _monthNames[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  return '$day $monthName ${date.year}';
}

List<int> _buildYearOptions(DateTime firstDate, DateTime lastDate) {
  final years = <int>[];
  for (int year = lastDate.year; year >= firstDate.year; year--) {
    years.add(year);
  }
  return years;
}

/// Presents the custom-styled date picker dialog.
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CustomDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

/// Presents the range-enabled version of the custom-styled date picker dialog.
Future<DateTimeRange?> showCustomDateRangePicker({
  required BuildContext context,
  required DateTimeRange initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CustomDateRangePickerDialog(
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CustomDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() =>
      _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final clamped = _clampToRange(widget.initialDate);
    _selectedDate = clamped;
    _displayedMonth = DateTime(clamped.year, clamped.month);
  }

  DateTime _clampToRange(DateTime date) {
    if (date.isBefore(widget.firstDate)) return widget.firstDate;
    if (date.isAfter(widget.lastDate)) return widget.lastDate;
    return date;
  }

  void _changeMonth(int delta) {
    final candidate =
        DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    final firstAllowed =
        DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastAllowed = DateTime(widget.lastDate.year, widget.lastDate.month);
    final monthStart = DateTime(candidate.year, candidate.month);
    if (monthStart.isBefore(firstAllowed) || monthStart.isAfter(lastAllowed)) {
      return;
    }
    setState(() {
      _displayedMonth = monthStart;
      if (_selectedDate.year == monthStart.year &&
          _selectedDate.month == monthStart.month) {
        return;
      }
      _selectedDate = _clampToRange(
        DateTime(monthStart.year, monthStart.month, _selectedDate.day),
      );
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, month, 1);
      _selectedDate = _clampToRange(
        DateTime(_displayedMonth.year, month, _selectedDate.day),
      );
    });
  }

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month, 1);
      _selectedDate = _clampToRange(
        DateTime(year, _selectedDate.month, _selectedDate.day),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _formatDisplayDate(_selectedDate);

    return AlertDialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 900,
        height: 586,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildCalendarColumn(selectedLabel),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildMonthColumn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarColumn(String selectedLabel) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withAlpha((0.1 * 255).round())),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                    splashRadius: 20,
                  ),
                  _buildMonthYearDropdown(),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CalendarGrid(
                displayedMonth: _displayedMonth,
                selectedDate: _selectedDate,
                minDate: widget.firstDate,
                maxDate: widget.lastDate,
                onDateSelected: (value) {
                  setState(() {
                    _selectedDate = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).round())),
          ),
          child: const Center(
            child: Text(
              'Pilih Bulan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(_monthNames.length, (index) {
                final monthIndex = index + 1;
                final isActive = _displayedMonth.month == monthIndex;
                return SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor:
                          isActive ? AppColors.primary : AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _selectMonth(monthIndex),
                    child: Text(
                      _monthNames[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).round())),
          ),
          child: Center(
            child: Text(
              _formatDisplayDate(_selectedDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryActive,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                // width: 120,
                child: Button.outlined(
                  borderColor: AppColors.grey,
                  color: AppColors.greyLight,
                  textColor: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  borderRadius: 8,
                  label: 'Batal',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: SizedBox(
                // width: 120,
                child: Button.filled(
                  label: 'Simpan',
                  onPressed: () => Navigator.of(context).pop(_selectedDate),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthYearDropdown() {
    final years = _buildYearOptions(widget.firstDate, widget.lastDate);
    final monthName = _monthNames[_displayedMonth.month - 1];
    return PopupMenuButton<int>(
      color: AppColors.white,
      onSelected: _selectYear,
      itemBuilder: (context) => years
          .map(
            (year) => PopupMenuItem<int>(
              value: year,
              child: Text(
                '$year',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: year == _displayedMonth.year
                      ? AppColors.primary
                      : AppColors.black,
                ),
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$monthName ${_displayedMonth.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CustomDateRangePickerDialog({
    required this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<_CustomDateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final clampedStart = _clampToRange(widget.initialDateRange.start);
    final clampedEnd = _clampToRange(widget.initialDateRange.end);
    if (clampedEnd.isBefore(clampedStart)) {
      _startDate = clampedEnd;
      _endDate = clampedStart;
    } else {
      _startDate = clampedStart;
      _endDate = clampedEnd;
    }
    final anchor = _endDate ?? _startDate ?? widget.firstDate;
    _displayedMonth = DateTime(anchor.year, anchor.month);
  }

  DateTime _clampToRange(DateTime date) {
    if (date.isBefore(widget.firstDate)) return widget.firstDate;
    if (date.isAfter(widget.lastDate)) return widget.lastDate;
    return date;
  }

  void _changeMonth(int delta) {
    final candidate =
        DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    final firstAllowed =
        DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastAllowed = DateTime(widget.lastDate.year, widget.lastDate.month);
    final monthStart = DateTime(candidate.year, candidate.month);
    if (monthStart.isBefore(firstAllowed) || monthStart.isAfter(lastAllowed)) {
      return;
    }
    setState(() {
      _displayedMonth = monthStart;
    });
  }

  void _selectMonth(int month) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, month, 1);
    });
  }

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month, 1);
    });
  }

  void _handleDateSelected(DateTime date) {
    final clamped = _clampToRange(date);
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = clamped;
        _endDate = null;
      } else {
        if (clamped.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = clamped;
        } else {
          _endDate = clamped;
        }
      }
    });
  }

  bool get _canSave => _startDate != null;

  DateTimeRange _currentRange() {
    final start = _startDate!;
    final end = _endDate ?? start;
    return DateTimeRange(start: start, end: end);
  }

  String _startLabel() =>
      _startDate != null ? _formatDisplayDate(_startDate!) : 'Belum dipilih';

  String _endLabel() {
    final effectiveEnd = _endDate ?? _startDate;
    if (effectiveEnd == null) return 'Belum dipilih';
    return _formatDisplayDate(effectiveEnd);
  }

  String _rangeSummary() {
    if (_startDate == null) {
      return 'Pilih rentang tanggal';
    }
    if (_endDate == null || _startDate!.isAtSameMomentAs(_endDate!)) {
      return _formatDisplayDate(_startDate!);
    }
    return '${_formatDisplayDate(_startDate!)} - ${_formatDisplayDate(_endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 900,
        height: 586,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildCalendarColumn(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildMonthColumn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarColumn() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mulai',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _startLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selesai',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _endLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withAlpha((0.1 * 255).round())),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                    splashRadius: 20,
                  ),
                  _buildMonthYearDropdown(),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CalendarGrid(
                displayedMonth: _displayedMonth,
                minDate: widget.firstDate,
                maxDate: widget.lastDate,
                rangeStart: _startDate,
                rangeEnd: _endDate,
                onDateSelected: _handleDateSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).round())),
          ),
          child: const Center(
            child: Text(
              'Pilih Bulan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(_monthNames.length, (index) {
                final monthIndex = index + 1;
                final isActive = _displayedMonth.month == monthIndex;
                return SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor:
                          isActive ? AppColors.primary : AppColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _selectMonth(monthIndex),
                    child: Text(
                      _monthNames[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha((0.3 * 255).round())),
          ),
          child: Center(
            child: Text(
              _rangeSummary(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryActive,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                child: Button.outlined(
                  borderColor: AppColors.grey,
                  color: AppColors.greyLight,
                  textColor: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  borderRadius: 8,
                  label: 'Batal',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: SizedBox(
                child: Button.filled(
                  label: 'Simpan',
                  disabled: !_canSave,
                  onPressed: () => Navigator.of(context).pop(_currentRange()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthYearDropdown() {
    final years = _buildYearOptions(widget.firstDate, widget.lastDate);
    final monthName = _monthNames[_displayedMonth.month - 1];
    return PopupMenuButton<int>(
      color: AppColors.white,
      onSelected: _selectYear,
      itemBuilder: (context) => years
          .map(
            (year) => PopupMenuItem<int>(
              value: year,
              child: Text(
                '$year',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: year == _displayedMonth.year
                      ? AppColors.primary
                      : AppColors.black,
                ),
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$monthName ${_displayedMonth.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarGrid({
    required this.displayedMonth,
    this.selectedDate,
    this.rangeStart,
    this.rangeEnd,
    required this.minDate,
    required this.maxDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <DateTime>[];
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(displayedMonth.year, displayedMonth.month - 1,
          DateTime(displayedMonth.year, displayedMonth.month, 0).day - i));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(displayedMonth.year, displayedMonth.month, day));
    }
    final trailing = (7 - days.length % 7) % 7;
    for (int day = 1; day <= trailing; day++) {
      days.add(DateTime(displayedMonth.year, displayedMonth.month + 1, day));
    }

    const weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isCurrentMonth = date.month == displayedMonth.month;
            final hasSelectedDate = selectedDate != null;
            final isSelected = hasSelectedDate &&
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
            final start = rangeStart;
            final end = rangeEnd ?? rangeStart;
            final isRangeMode = start != null;
            final isRangeStart =
                isRangeMode && start != null && _isSameDate(date, start);
            final isRangeEnd =
                isRangeMode && end != null && _isSameDate(date, end!);
            final isInBetween = isRangeMode &&
                start != null &&
                end != null &&
                date.isAfter(start) &&
                date.isBefore(end!);
            final inRange = !date.isBefore(minDate) && !date.isAfter(maxDate);

            Color background;
            Color textColor;
            if (!inRange) {
              background = Colors.grey.shade200;
              textColor = Colors.grey;
            } else if (isRangeMode && (isRangeStart || isRangeEnd)) {
              background = AppColors.primaryLight;
              textColor = AppColors.primaryActive;
            } else if (isRangeMode && isInBetween) {
              background = AppColors.primaryLight.withOpacity(0.4);
              textColor = AppColors.primaryActive;
            } else if (isSelected) {
              background = AppColors.primaryLight;
              textColor = AppColors.primaryActive;
            } else if (isCurrentMonth) {
              background = Colors.white;
              textColor = AppColors.black;
            } else {
              background = Colors.grey.shade100;
              textColor = Colors.grey;
            }

            return GestureDetector(
              onTap: inRange
                  ? () {
                      onDateSelected(date);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isRangeMode && (isRangeStart || isRangeEnd)) ||
                            isSelected
                        ? AppColors.primaryActive
                        : Colors.black.withAlpha((0.05 * 255).round()),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
