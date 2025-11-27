import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/services/feature_availability_service.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

/// Widget wrapper yang otomatis disable/menampilkan pesan untuk fitur yang memerlukan online
/// Jika fitur tidak tersedia (offline), widget akan di-disable dan menampilkan tooltip
class FeatureGuard extends StatelessWidget {
  final String featureCode;
  final Widget child;
  final Widget? disabledChild;
  final String? customMessage;
  final bool showTooltip;
  final VoidCallback? onDisabledTap;

  const FeatureGuard({
    super.key,
    required this.featureCode,
    required this.child,
    this.disabledChild,
    this.customMessage,
    this.showTooltip = true,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineCheckerBloc, OnlineCheckerState>(
      builder: (context, state) {
        final featureService = FeatureAvailabilityService(
          context.read<OnlineCheckerBloc>(),
        );
        final isAvailable = featureService.isFeatureAvailable(featureCode);

        if (isAvailable) {
          return child;
        }

        // Jika disabled, tampilkan disabled child atau wrap dengan disabled
        if (disabledChild != null) {
          return _buildWithTooltip(
            context,
            featureService,
            disabledChild!,
          );
        }

        return _buildDisabledWrapper(context, featureService);
      },
    );
  }

  Widget _buildDisabledWrapper(
    BuildContext context,
    FeatureAvailabilityService service,
  ) {
    final message = customMessage ?? service.getUnavailableMessage(featureCode);

    return Tooltip(
      message: showTooltip ? message : '',
      child: GestureDetector(
        onTap: onDisabledTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
        child: Opacity(
          opacity: 0.5,
          child: AbsorbPointer(
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildWithTooltip(
    BuildContext context,
    FeatureAvailabilityService service,
    Widget disabledWidget,
  ) {
    final message = customMessage ?? service.getUnavailableMessage(featureCode);

    return Tooltip(
      message: showTooltip ? message : '',
      child: GestureDetector(
        onTap: onDisabledTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
        child: disabledWidget,
      ),
    );
  }
}
