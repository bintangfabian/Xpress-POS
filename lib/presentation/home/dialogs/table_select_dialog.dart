import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';

class TableSelectDialog extends StatefulWidget {
  final int initialTable;
  const TableSelectDialog({super.key, this.initialTable = 0});

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
              icon: Assets.icons.cancel.svg(
                colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                height: 32,
                width: 32,
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: 484,
        child: BlocBuilder<GetTableBloc, GetTableState>(
          builder: (context, state) {
            return state.maybeWhen(
              success: (tables) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 360,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 32,
                        mainAxisSpacing: 32,
                        childAspectRatio: 91 / 50,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (_, i) {
                        final table = tables[i];
                        final tableNumber =
                            int.tryParse(table.tableNumber ?? '0') ?? 0;
                        final isSelected = selected == tableNumber;
                        final isAvailable =
                            table.status.toLowerCase() == 'available';
                        final isOccupied =
                            table.status.toLowerCase() == 'occupied';
                        final isReserved =
                            table.status.toLowerCase() == 'reserved';

                        Color statusColor;
                        Color textColor;

                        if (isSelected) {
                          statusColor = AppColors.success;
                          textColor = AppColors.white;
                        } else if (isAvailable) {
                          statusColor = AppColors.successLight;
                          textColor = AppColors.success;
                        } else if (isOccupied) {
                          statusColor = AppColors.dangerLight;
                          textColor = AppColors.danger;
                        } else if (isReserved) {
                          statusColor = AppColors.warningLight;
                          textColor = AppColors.warning;
                        } else {
                          statusColor = AppColors.greyLight;
                          textColor = AppColors.grey;
                        }

                        return InkWell(
                          onTap: isAvailable
                              ? () => setState(() => selected = tableNumber)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: textColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Meja $tableNumber',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isAvailable) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      isOccupied
                                          ? 'Terpakai'
                                          : isReserved
                                              ? 'Reservasi'
                                              : 'Tidak Tersedia',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // const SpaceHeight(16),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              orElse: () => const Center(
                child: Text('Gagal memuat data meja'),
              ),
            );
          },
        ),
      ),
      actions: [
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
        ),
      ],
    );
  }
}
