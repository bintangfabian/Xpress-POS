import 'package:flutter/material.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/constants/colors.dart';
import '../models/tax_model.dart';

class ManageTaxCard extends StatelessWidget {
  final TaxModel data;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;

  const ManageTaxCard({
    super.key,
    required this.data,
    required this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _CellContent(
              icon: Assets.icons.bill.svg(
                height: 24,
                width: 24,
                color: AppColors.primary,
              ),
              text: data.name,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _typeLabel(data.type),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${data.value}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  color: AppColors.primary,
                  icon: Assets.icons.editUnderline
                      .svg(height: 16, width: 16, color: AppColors.white),
                  onTap: onEditTap,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  color: AppColors.danger,
                  icon: Assets.icons.trash
                      .svg(height: 16, width: 16, color: AppColors.white),
                  onTap: onDeleteTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(TaxType type) {
    return type.isLayanan ? 'Layanan' : 'Pajak';
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: icon,
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final Widget icon;
  final String text;

  const _CellContent({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
