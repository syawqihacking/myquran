import 'package:flutter/material.dart';

import '../../core/app_layout.dart';

/// A section container used to group related settings with a title.
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: AppLayout.sp2),
        Container(
          margin: const EdgeInsets.only(bottom: AppLayout.sp6),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// A single setting row with an icon, title, optional subtitle, trailing
/// widget, and optional bottom widget.
class SettingRow extends StatefulWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isDestructive = widget.destructive;
    final iconBg = isDestructive
        ? scheme.errorContainer.withValues(alpha: 0.5)
        : scheme.primaryContainer.withValues(alpha: 0.3);
    final iconColor = isDestructive ? scheme.error : scheme.primary;

    final content = AnimatedContainer(
      duration: AppLayout.durBase,
      color: _hovered && widget.onTap != null
          ? scheme.surfaceContainerHigh.withValues(alpha: 0.5)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
            ),
            child: Icon(widget.icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppLayout.sp4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? scheme.error : null,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (widget.bottom != null) ...[
                  const SizedBox(height: AppLayout.sp3),
                  widget.bottom!,
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: AppLayout.sp3),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hovered = v),
        child: content,
      ),
    );
  }
}

/// A keyboard shortcut row showing an icon, label, and key badges.
class ShortcutRow extends StatelessWidget {
  const ShortcutRow({
    super.key,
    required this.icon,
    required this.label,
    required this.keys,
  });

  final IconData icon;
  final String label;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp4,
        vertical: AppLayout.sp3,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppLayout.sp3),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          for (final k in keys) ...[
            Container(
              margin: const EdgeInsets.only(left: AppLayout.sp1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.sp2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                k,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small pill showing a status value (e.g. data version, license) on the
/// trailing side of a [SettingRow].
class ValueChip extends StatelessWidget {
  const ValueChip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// A horizontal divider that aligns with the content of a [SettingRow].
class DividerRow extends StatelessWidget {
  const DividerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppLayout.sp4 + 20 + AppLayout.sp3,
      endIndent: AppLayout.sp4,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
