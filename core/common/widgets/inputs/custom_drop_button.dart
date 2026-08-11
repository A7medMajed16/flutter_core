import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_widget_theme.dart';
import '../../../theme/scroll_bar_theme.dart';
import 'custom_input_border.dart';
import 'custom_text_field.dart';

class CustomDropButton<T> extends StatefulWidget {
  const CustomDropButton({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    this.hint,
    this.validator,
    this.withUpdate = true,
    this.headerTextStyle,
    this.spacing = 0,
    this.radius = 12,
    this.borderColor = Colors.transparent,
    this.height,
    this.enabled = true,
    this.prefixIcon,
    this.recolorIcon = true,
    this.preferLazyModal = false,
    this.enableSearchInModal = false,
    this.searchHint,
    this.isWeb = false,
    this.prefixIconColor,
    this.alignment = AlignmentDirectional.topStart,
    this.title,
    this.titleStyle,
  });
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T? selectedValue)? onChanged;
  final String? hint, prefixIcon;
  final String? Function(T? value)? validator;
  final bool withUpdate, enabled, recolorIcon, isWeb;
  final double? spacing, radius, height;
  final TextStyle? headerTextStyle, titleStyle;
  final String? title;
  final Color? borderColor, prefixIconColor;

  final bool preferLazyModal;
  final bool enableSearchInModal;
  final String? searchHint;
  final AlignmentGeometry alignment;

  @override
  State<CustomDropButton<T>> createState() =>
      _CustomDropButtonState<T>();
}

class _CustomDropButtonState<T> extends State<CustomDropButton<T>> {
  T? _localValue; // for immediate UI feedback in modal mode
  bool _enabled = true;

  @override
  void initState() {
    if (widget.items.isEmpty) {
      _enabled = false;
    } else {
      _enabled = widget.enabled;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomDropButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent value changes, sync local
    if (widget.value != oldWidget.value) {
      _localValue = widget.value;
    }
  }

  String? _labelForValue(T? v) {
    if (v == null) return null;
    for (final item in widget.items) {
      if (item.value == v) {
        final child = item.child;
        if (child is Text) return child.data;
        // Fallback: not a Text, return value as String
        return item.value.toString();
      }
    }
    // Fallback if not found in items
    return v is String ? v : v.toString();
  }

  Future<void> _openModalPicker() async {
    if (!_enabled) return;
    final selectedBefore = _localValue ?? widget.value;
    T? result;

    if (widget.isWeb && widget.preferLazyModal) {
      // Show dialog on web with same UI as bottom sheet
      result = await showDialog<T>(
        context: context,
        barrierDismissible: true,

        builder: (ctx) {
          List<DropdownMenuItem<T>> filtered = widget.items;
          final controller = TextEditingController();
          return StatefulBuilder(
            builder: (context, setSB) {
              final size = MediaQuery.of(context).size;
              double dialogWidth = size.width * 0.9;
              if (dialogWidth > 640) dialogWidth = 640;
              double dialogHeight = size.height * 0.85;
              if (dialogHeight > 560) dialogHeight = 560;
              return AlertDialog(
                backgroundColor: AppColors.originalWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: dialogWidth,
                  height: dialogHeight,
                  color: AppColors.originalWhite,
                  child: Column(
                    children: [
                      if (widget.enableSearchInModal)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CustomTextFormField(
                            controller: controller,
                            hintText:
                                widget.searchHint ??
                                "custom_widget.search".tr(),
                            suffixWidget: Icon(Icons.search),
                            textDirection: TextDirection.ltr,

                            onChanged: (q) {
                              final query = q!.trim().toLowerCase();
                              setSB(() {
                                filtered = widget.items.where((e) {
                                  final w = e.child;
                                  String text = '';
                                  if (w is Text) {
                                    text = w.data ?? '';
                                  } else {
                                    text = e.value?.toString() ?? '';
                                  }
                                  return text.toLowerCase().contains(
                                    query,
                                  );
                                }).toList();
                              });
                            },
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: ScrollConfiguration(
                            behavior: NoScrollbarBehavior(),
                            child: ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final isSelected =
                                    item.value == selectedBefore;
                                return ListTile(
                                  title: item.child,
                                  titleTextStyle: 16.regular.copyWith(
                                    color: AppColors.originalBlack,
                                  ),
                                  titleAlignment:
                                      ListTileTitleAlignment.center,
                                  selectedTileColor: AppColors
                                      .primerColor
                                      .withValues(alpha: 0.1),
                                  selected: isSelected,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  onTap: () =>
                                      context.pop(item.value),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      result = await showModalBottomSheet<T>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: AppColors.originalWhite,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (ctx) {
          List<DropdownMenuItem<T>> filtered = widget.items;
          final controller = TextEditingController();
          return StatefulBuilder(
            builder: (context, setSB) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                maxChildSize: 0.9,
                minChildSize: 0.4,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      if (widget.enableSearchInModal)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CustomTextFormField(
                            controller: controller,
                            hintText:
                                widget.searchHint ??
                                "custom_widget.search".tr(),
                            // prefixIcon:
                            //     AppIcons.coreCommonAssetsIconsSearch,
                            onChanged: (q) {
                              final query = q!.trim().toLowerCase();
                              setSB(() {
                                filtered = widget.items.where((e) {
                                  final w = e.child;
                                  String text = '';
                                  if (w is Text) {
                                    text = w.data ?? '';
                                  } else {
                                    text = e.value?.toString() ?? '';
                                  }
                                  return text.toLowerCase().contains(
                                    query,
                                  );
                                }).toList();
                              });
                            },
                          ),
                        ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: ScrollConfiguration(
                              behavior: NoScrollbarBehavior(),
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected =
                                      item.value == selectedBefore;
                                  return ListTile(
                                    title: item.child,
                                    titleTextStyle: 16.regular
                                        .copyWith(
                                          color:
                                              AppColors.originalBlack,
                                        ),
                                    selectedTileColor: AppColors
                                        .primerColor
                                        .withValues(alpha: 0.1),
                                    selected: isSelected,
                                    titleAlignment:
                                        ListTileTitleAlignment.center,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    onTap: () =>
                                        context.pop(item.value),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    }
    setState(() => _localValue = result);
    widget.onChanged?.call(result);
    if (context.mounted) {
      // ignore: use_build_context_synchronously
      FocusScope.of(context).unfocus();
    }
  }

  InputDecoration _decoration() {
    return InputDecoration(
      prefixIconConstraints: const BoxConstraints(
        minWidth: 0,
        minHeight: 0,
      ),
      isDense: true,
      contentPadding: REdgeInsetsDirectional.only(
        start: 12,
        end: 12,
        bottom: 10,
        top: 10,
      ),
      prefixIcon: (widget.prefixIcon != null)
          ? Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 12,
                end: 8,
              ),
              child: SvgPicture.asset(
                widget.prefixIcon!,
                width: 20,
                height: 20,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                  _enabled
                      ? (widget.prefixIconColor ??
                            AppWidgetTheme.textFieldPrefixIconColor)
                      : (widget.prefixIconColor ??
                                AppWidgetTheme
                                    .textFieldPrefixIconColor)
                            .withValues(alpha: 0.3),
                  BlendMode.srcIn,
                ),
              ),
            )
          : null,
      fillColor: _enabled
          ? AppWidgetTheme.textFieldFillColor
          : AppWidgetTheme.textFieldDisabledFillColor,
      filled: true,
      focusColor: Colors.black,
      errorStyle: 12.regular.copyWith(
        color: AppWidgetTheme.textFieldErrorTextColor,
      ),
      hoverColor: AppWidgetTheme.textFieldHoverColor,
      errorMaxLines: 4,
      errorBorder: customOutLineBorders(
        borderColor: AppColors.originalRed,
      ),
      enabledBorder: customOutLineBorders(
        borderRadius: widget.radius,
        borderColor: widget.borderColor != Colors.transparent
            ? widget.borderColor
            : null,
      ),
      border: customOutLineBorders(borderRadius: widget.radius),
      focusedBorder: customOutLineBorders(
        borderRadius: widget.radius,
        borderColor: AppColors.primerColor,
        borderWidth: 1.5,
      ),
      disabledBorder: customOutLineBorders(
        borderRadius: widget.radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _localValue ?? widget.value;
    final selectedLabel = _labelForValue(currentValue);

    Widget child;
    if (!widget.preferLazyModal) {
      // Original dropdown path
      child = SizedBox(
        height: widget.height,
        child: DropdownButtonFormField<T>(
          items: widget.items,
          key: widget.withUpdate ? null : UniqueKey(),
          initialValue: widget.value,
          menuMaxHeight: 240,
          onChanged: _enabled
              ? (value) {
                  widget.onChanged?.call(value);
                  FocusScope.of(context).unfocus();
                }
              : null,
          isExpanded: true,
          autofocus: false,
          validator: widget.validator,
          alignment: widget.alignment,
          hint: Text(
            widget.hint ?? "",
            style: 14.light.copyWith(
              color: _enabled
                  ? AppWidgetTheme.textFieldHintColor
                  : AppWidgetTheme.textFieldDisabledHintColor,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: _enabled ? AppColors.gray99 : AppColors.grayB6,
          ),
          decoration: _decoration(),
          elevation: 9,
          borderRadius: BorderRadius.circular(widget.radius!),
          dropdownColor: AppWidgetTheme.textFieldFillColor,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: 16.regular.copyWith(color: AppColors.originalBlack),
        ),
      );
    } else {
      // Lazy modal path for large datasets
      child = FormField<T>(
        validator: widget.validator,
        initialValue: currentValue,
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _enabled ? _openModalPicker : null,
                child: InputDecorator(
                  isEmpty:
                      (selectedLabel == null ||
                      selectedLabel.isEmpty),
                  decoration: _decoration().copyWith(
                    errorText: state.hasError
                        ? state.errorText
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          selectedLabel ?? (widget.hint ?? ''),
                          style:
                              (selectedLabel == null ||
                                  selectedLabel.isEmpty)
                              ? 14.light.copyWith(
                                  color: AppWidgetTheme
                                      .textFieldHintColor,
                                )
                              : 16.regular,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 24,
                        color: _enabled
                            ? AppColors.gray99
                            : AppColors.grayB6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        if (widget.title != null && widget.title!.isNotEmpty)
          Text(
            widget.title ?? "",
            style:
                widget.titleStyle ??
                14.light.copyWith(
                  color: AppWidgetTheme.textFieldTitleColor,
                ),
          ),
        child,
      ],
    );
  }
}
