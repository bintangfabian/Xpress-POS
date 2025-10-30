import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/components.dart';
import 'package:xpress/core/constants/colors.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedTab = 0; // 0 semua, 1 paket, 2 ala carte, 3 minuman

  final _tabs = const ['Semua', 'Paket', 'Ala Carte', 'Minuman'];

  final List<_InvItem> _items = List.generate(
    8,
    (i) => _InvItem(
      name: 'Ayam Goreng Paha',
      price: 20000,
      stock: 10,
      sold: 56,
      image: Assets.images.menu1,
      status: i % 3 == 1 ? _InvStatus.low : _InvStatus.good,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final items = _items
        .where((e) =>
            e.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ContentTitle('Inventori'),
          const SpaceHeight(16),

          // Search + sort
          Row(
            children: [
              Expanded(
                child: SearchInput(
                  controller: _searchCtrl,
                  hintText: 'Search Menu',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.06 * 255).round()),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Assets.icons.sort.svg(
                    height: 20,
                    width: 20,
                    colorFilter:
                        ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  ),
                ),
              )
            ],
          ),

          const SpaceHeight(16),

          // Tabs
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(
              _tabs.length,
              (i) => _TabChip(
                label: _tabs[i],
                isActive: _selectedTab == i,
                onTap: () => setState(() => _selectedTab = i),
              ),
            ),
          ),

          const SpaceHeight(16),

          // Header row
          Row(
            children: const [
              _HeaderCell('Gambar', flex: 2),
              _HeaderCell('Menu', flex: 5),
              _HeaderCell('Stok Tersisa', flex: 2),
              _HeaderCell('Terjual', flex: 2),
              _HeaderCell('Status', flex: 3),
            ],
          ),

          const SizedBox(height: 8),

          // List
          Column(
            children: items
                .map((e) => _InventoryRow(
                      item: e,
                    ))
                .toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _InvStatus { good, low }

class _InvItem {
  final String name;
  final int price;
  final int stock;
  final int sold;
  final AssetGenImage image;
  final _InvStatus status;
  _InvItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.sold,
    required this.image,
    required this.status,
  });
}

class _InventoryRow extends StatelessWidget {
  final _InvItem item;
  const _InventoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isGood = item.status == _InvStatus.good;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Gambar
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.image.image(height: 52, width: 52, fit: BoxFit.cover),
            ),
          ),
          // Menu
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 16)),
                Text('@Rp${item.price.toStringAsFixed(0)}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('${item.stock}', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text('${item.sold}', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      isGood ? AppColors.successLight : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isGood ? 'Good' : 'Low',
                  style: TextStyle(
                    color: isGood ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
