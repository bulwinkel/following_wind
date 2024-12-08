import 'package:flutter/widgets.dart';
import 'package:following_wind/src/widgets/fw_default_text_and_icon_style.dart';
import 'package:following_wind/src/widgets/fw_size.dart';

import 'class_groups.dart';
import 'colors.dart';
import 'following_wind.dart';
import 'spacings.dart';
import 'support_internal.dart';
import 'widgets/fw_decorated_box.dart';
import 'widgets/fw_flex.dart';
import 'widgets/fw_padding.dart';

// ignore: camel_case_types
class Box extends StatelessWidget {
  const Box({
    super.key,
    this.className = '',
    this.classNames = const [],
    this.onPressed,
    this.children = const [],
  });

  final String className;
  final List<String> classNames;
  final List<Widget> children;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final classes = collectClasses(className, classNames);
    // dpl('classes: $classMap');

    if (classes.contains('hidden')) {
      return const SizedBox.shrink();
    }

    final fw = FollowingWind.of(context);
    // dpl('fw: $fw');

    T findValueForClass<T>(
      Map<String, T> lookup,
      T defaultValue,
    ) {
      T? result;

      for (final className in lookup.keys) {
        if (classes.contains(className)) {
          result = lookup[className];
          break;
        }
      }

      return result ?? defaultValue;
    }

    // Group classes by their type
    final classGroups = ClassGroups.fromClasses(classes);

    // Configure the layout first by processing all layout classes together
    Widget child = FwFlex(
      spacingMultiplier: fw.spacingScale,
      spacings: spacings.keys.toList(),
      findValueForClass: findValueForClass,
      children: children,
    );

    // Apply text styles
    child = FwDefaultTextAndIconStyle(
      spacingMultiplier: fw.spacingScale,
      classKey: 'text',
      findValueForClass: findValueForClass,
      colors: colors,
      child: child,
    );

    // internal spacing
    child = FwPadding(
      edgeInsets: fw.paddings,
      classes: classes,
      child: child,
    );

    child = FwDecoratedBox(
      classes: classes,
      bgColors: fw.bgColors,
      borderColor: fw.borderColor,
      borderColors: fw.borderColors,
      borderWidths: fw.borderWidths,
      borderRadiuses: fw.borderRadiuses,
      child: child,
    );

    // Size the box before applying external spacing
    child = FwSize(
      sizes: fw.sizes,
      widths: fw.widths,
      heights: fw.heights,
      findValueForClass: findValueForClass,
      child: child,
    );

    if (onPressed != null) {
      child = GestureDetector(
        onTap: onPressed,
        child: child,
      );
    }

    // external spacing
    child = FwPadding(
      edgeInsets: fw.margins,
      classes: classes,
      child: child,
    );

    return child;
  }
}

Widget box(
  String className,
  List<Widget> children, {
  Key? key,
}) {
  return Box(
    key: key,
    className: className,
    children: children,
  );
}
