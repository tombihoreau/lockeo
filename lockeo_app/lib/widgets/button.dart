import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    const teal = AppColors.primaryBlue;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.white : teal,
          foregroundColor: outlined ? teal : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          side: outlined
              ? const BorderSide(color: AppColors.primaryBlue, width: 1)
              : BorderSide.none,
          elevation: 0,
        ),
        child: Text(
          text,
          style: AppTextStyles.number.copyWith(
            color: outlined ? teal : Colors.white,
          ),
        ),
      ),
    );
  }
}
