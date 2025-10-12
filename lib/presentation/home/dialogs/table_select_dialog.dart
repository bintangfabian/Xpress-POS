import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/spaces.dart';
import 'package:xpress/core/constants/colors.dart';

class TableSelectDialog extends StatefulWidget {
  final int initialTable;
  final int tableCount;
  const TableSelectDialog(
      {super.key, this.initialTable = 0, this.tableCount = 24});

  @override
  State<TableSelectDialog> createState() => _TableSelectDialogState();
}

class _TableSelectDialogState extends State<TableSelectDialog> {
  int? selected;

  @override
  void initState() {
    selected = widget.initialTable > 0 ? widget.initialTable : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('NOMOR MEJA',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 32, fontFamily: '')),
            IconButton(
              icon: Assets.icons.cancel
                  .svg(color: AppColors.grey, height: 32, width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: 484,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 360,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 32,
                  mainAxisSpacing: 32,
                  childAspectRatio: 91 / 50,
                ),
                itemCount: widget.tableCount,
                itemBuilder: (_, i) {
                  final num = i + 1;
                  final isSelected = selected == num;
                  return InkWell(
                    onTap: () => setState(() => selected = num),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.success
                            : AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.success
                              : AppColors.success,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Meja $num',
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.successLight
                                : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SpaceHeight(16),
            Row(
              children: [
                Expanded(
                  child: Button.outlined(
                    label: 'Kembali',
                    color: AppColors.greyLight,
                    borderColor: AppColors.grey,
                    textColor: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Button.filled(
                    color: AppColors.success,
                    label: 'Apply',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    onPressed: () => Navigator.pop(context, selected),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
