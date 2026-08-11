import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../../features/splash/presentation/widgets/animated_logo.dart';

class AlFaresLoadingWidget extends StatelessWidget {
  const AlFaresLoadingWidget({
    super.key,
    this.logoWidth = 140,
    this.showBackground = true,
  });

  final double logoWidth;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final logo = AnimatedLogo(
      mode: LogoAnimationMode.loading,
      logoWidth: logoWidth,
    );

    if (!showBackground) return Center(child: logo);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primerGradient,
      ),
      child: Center(child: logo),
    );
  }
}
