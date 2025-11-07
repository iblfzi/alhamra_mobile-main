import 'package:flutter/material.dart';
import '../../../core/utils/app_styles.dart';

class CustomCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const CustomCardWidget({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppStyles.getCardBorderRadius(context),
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: border,
      ),
      child: child,
    );
  }
}

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final String buttonText;
  final IconData? buttonIcon;
  final String historyText;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onHistoryPressed;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final bool isAmountHidden;
  final VoidCallback? onToggleVisibility;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.amount,
    this.buttonText = '',
    this.buttonIcon,
    required this.historyText,
    this.onButtonPressed,
    this.onHistoryPressed,
    this.onRefresh,
    this.isRefreshing = false,
    this.isAmountHidden = false,
    this.onToggleVisibility,
  });

  String _displayAmount() {
    if (isRefreshing) {
      return 'Rp ...';
    }
    return isAmountHidden ? '••••••••' : amount;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppStyles.saldoLabel(context)),
              if (onRefresh != null)
                GestureDetector(
                  onTap: onRefresh,
                  child: Row(
                    children: [
                      Text(
                        'Segarkan',
                        style: AppStyles.bodyText(context).copyWith(
                          color: AppStyles.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.sync,
                        color: AppStyles.primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _displayAmount(),
                    style: AppStyles.saldoValue(context),
                  ),
                  if (onToggleVisibility != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: Icon(
                        isAmountHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppStyles.lightGreyColor,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
              if (buttonText.isNotEmpty && onButtonPressed != null)
                GestureDetector(
                  onTap: onButtonPressed,
                  child: Column(
                    children: [
                      Icon(buttonIcon, color: AppStyles.primaryColor, size: 24),
                      const SizedBox(height: 4),
                      Text(buttonText, style: AppStyles.topUpButton(context)),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          const Divider(),
          if (onHistoryPressed != null)
            GestureDetector(
              onTap: onHistoryPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: AppStyles.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        historyText,
                        style: AppStyles.transactionHistory(context),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppStyles.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
