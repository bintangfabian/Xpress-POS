import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';
import 'package:xpress/data/models/response/member_detail_response_model.dart';

class MemberDetailDialog extends StatefulWidget {
  final String memberId;

  const MemberDetailDialog({
    super.key,
    required this.memberId,
  });

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  late Future<MemberDetailResponseModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadMemberDetail();
  }

  Future<MemberDetailResponseModel> _loadMemberDetail() async {
    final result =
        await MemberRemoteDatasource().getMemberDetail(widget.memberId);
    return result.fold(
      (error) => MemberDetailResponseModel(status: 'error'),
      (data) => data,
    );
  }

  Color _getTierColor(String? tierName) {
    switch (tierName?.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy, HH:mm').format(parsed);
    } catch (_) {
      return dateTime;
    }
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
            const Text(
              'Detail Member',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            IconButton(
              icon: Assets.icons.cancel.svg(
                  colorFilter:
                      const ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                  height: 32,
                  width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: FutureBuilder<MemberDetailResponseModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError || snapshot.data?.data == null) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Gagal memuat detail member',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final member = snapshot.data!.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Member Basic Info
                  _buildMemberHeaderCard(member),

                  const SizedBox(height: 20),

                  // Tier Progress Card
                  _buildTierCard(member),

                  const SizedBox(height: 20),

                  // Statistics Cards Row
                  _buildStatisticsRow(member),

                  const SizedBox(height: 20),

                  // Additional Info Card
                  _buildAdditionalInfoCard(member),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberHeaderCard(MemberDetail member) {
    final tierName = member.currentTierName ?? 'Bronze';
    final tierColor = _getTierColor(tierName);
    final isActive = member.isActive ?? true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern - X shapes for Xpress POS (pure X without boxes)
          Positioned(
            right: 80,
            bottom: 0,
            child: Stack(
              children: [
                // First diagonal line (\)
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 15,
                    height: 150,
                    color: AppColors.white.withOpacity(0.15),
                  ),
                ),
                // Second diagonal line (/)
                Transform.rotate(
                  angle: -0.785398, // -45 degrees
                  child: Container(
                    width: 15,
                    height: 150,
                    color: AppColors.white.withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 240,
            top: -55,
            child: Stack(
              children: [
                // First diagonal line (\)
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 20,
                    height: 200,
                    color: AppColors.white.withOpacity(0.12),
                  ),
                ),
                // Second diagonal line (/)
                Transform.rotate(
                  angle: -0.785398, // -45 degrees
                  child: Container(
                    width: 20,
                    height: 200,
                    color: AppColors.white.withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 25,
            child: Stack(
              children: [
                // First diagonal line (\)
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 4,
                    height: 50,
                    color: AppColors.white.withOpacity(0.1),
                  ),
                ),
                // Second diagonal line (/)
                Transform.rotate(
                  angle: -0.785398, // -45 degrees
                  child: Container(
                    width: 4,
                    height: 50,
                    color: AppColors.white.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar with Status
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    // Status Indicator
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              isActive ? AppColors.success : AppColors.danger,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Icon(
                          isActive ? Icons.check : Icons.close,
                          size: 12,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Member Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.name ?? 'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Member Status Badge - right next to name
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.danger.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isActive ? 'AKTIF' : 'NONAKTIF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              member.memberNumber ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: tierColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tierName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Contact Info with improved styling
                      Container(
                        width: 250,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    member.email ?? '-',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  member.phone ?? '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(MemberDetail member) {
    final tierName = member.currentTierName ?? 'Bronze';
    final tierColor = _getTierColor(tierName);
    final currentPoints = member.loyaltyPoints ?? 0;
    final pointsToNext = member.pointsToNextTier ?? 1000;
    final totalPointsForNext = currentPoints + pointsToNext;
    final progress = totalPointsForNext > 0
        ? (currentPoints / totalPointsForNext).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tierColor),
        boxShadow: [
          BoxShadow(
            color: tierColor,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member Tier',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: tierColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  tierName.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress ke tier berikutnya',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${NumberFormat('#,##0', 'id_ID').format(currentPoints)} / ${NumberFormat('#,##0', 'id_ID').format(totalPointsForNext)} pts',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar with Stack
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                // Background bar (full width)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Progress bar
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${NumberFormat('#,##0', 'id_ID').format(pointsToNext)} points lagi untuk naik tier',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),

          // Tier Benefits
          if (member.tierDiscountPercentage != null &&
              member.tierDiscountPercentage! > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diskon ${member.tierDiscountPercentage}% untuk setiap transaksi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(MemberDetail member) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Pengeluaran',
            'Rp ${member.formattedTotalSpent ?? '0'}',
            Icons.account_balance_wallet,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Jumlah Kunjungan',
            '${member.visitCount ?? 0}x',
            Icons.store,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Rata-rata Order',
            'Rp ${NumberFormat('#,##0', 'id_ID').format(member.averageOrderValue ?? 0)}',
            Icons.trending_up,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(MemberDetail member) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyLightActive),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.cake_outlined,
            'Tanggal Lahir',
            _formatDate(member.dateOfBirth),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Alamat',
            member.address ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Kunjungan Terakhir',
            _formatDateTime(member.lastVisitAt),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Bergabung Sejak',
            _formatDate(member.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
