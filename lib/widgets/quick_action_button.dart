import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon; // תומך גם בווידג'ט אייקון (Lottie/Network וכו')
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;
  final String? tooltip;
  final bool loading;
  final bool disabled;
  final bool isCircle;

  const QuickActionButton({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 36,
    this.tooltip,
    this.loading = false,
    this.disabled = false,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color iconClr = iconColor ?? theme.colorScheme.primary;
    final Color bgClr = backgroundColor ??
        (theme.brightness == Brightness.light
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface.withOpacity(0.93));
    final Color contentClr = theme.colorScheme.onSurface;

    Widget iconWidget = loading
        ? Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(iconClr),
              ),
            ),
          )
        : (customIcon ?? Icon(icon, size: iconSize, color: iconClr));

    Widget buttonContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 10),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: contentClr,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    Widget decorated = Container(
      width: isCircle ? 84 : null,
      height: isCircle ? 84 : null,
      padding: isCircle ? const EdgeInsets.all(0) : const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: disabled ? bgClr.withOpacity(0.55) : bgClr,
        borderRadius: BorderRadius.circular(isCircle ? 99 : 18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.11),
        ),
      ),
      child: Center(child: buttonContent),
    );

    Widget clickable = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isCircle ? 99 : 18),
        onTap: (loading || disabled) ? null : onTap,
        splashColor: iconClr.withOpacity(0.14),
        highlightColor: iconClr.withOpacity(0.07),
        child: decorated,
      ),
    );

    return Tooltip(
      message: tooltip ?? label,
      child: clickable,
    );
  }
}
