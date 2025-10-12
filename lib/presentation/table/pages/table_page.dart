import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import 'package:xpress/presentation/table/dialogs/form_table_dialog.dart';
import 'package:xpress/presentation/table/widgets/card_table_widget.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  @override
  void initState() {
    context.read<GetTableBloc>().add(const GetTableEvent.getTables());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              const PageTitle(title: 'Dasbor Meja'),
              SpaceHeight(20),

              Button.filled(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FormTableDialog(),
                  );
                },
                label: 'Kelola Meja',
                height: 50.0,
                width: 142.0,
              ),
              SpaceHeight(24.0),

              // 🔹 GridView meja -> Expanded biar scrollable
              Expanded(
                child: BlocBuilder<GetTableBloc, GetTableState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      orElse: () {
                        return SizedBox.shrink();
                      },
                      loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      success: (tables) {
                        if (tables.isEmpty) {
                          return const Center(
                            child: Text('No table available'),
                          );
                        }
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 168 / 112,
                            crossAxisCount: 6,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 24,
                          ),
                          itemCount: tables.length,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return CardTableWidget(
                              table: tables[index],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SpaceHeight(4),
              // 🔹 Legend status (tidak ikut scroll)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LegendItem(
                      color: AppColors.successLight,
                      label: "Tersedia",
                    ),
                    SizedBox(width: 24),
                    LegendItem(
                      color: AppColors.warningLight,
                      label: "Reservasi",
                    ),
                    SizedBox(width: 24),
                    LegendItem(
                      color: AppColors.dangerLight,
                      label: "Terpakai",
                    ),
                    SizedBox(width: 24),
                    LegendItem(
                      color: AppColors.greyLight,
                      label: "Dalam Perbaikan",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
