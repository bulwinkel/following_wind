import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:following_wind/src/support.dart';

import 'class_groups.dart';
import 'colors.dart';
import 'exceptions.dart';

typedef ApplyClassName = Widget Function(Widget child, List<String> parts);

class ClassParser {
  static const spacingMultiplier = 4.0;

  // TODO: handle custom values in [] brackets, e.g. [24px]
  final Map<String, ApplyClassName> classNameLookup = {
    // region Padding
    'p': (child, parts) {
      return Padding(
        padding: EdgeInsets.all(parseToSpacing(parts)),
        child: child,
      );
    },
    'px': (child, parts) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: parseToSpacing(parts)),
        child: child,
      );
    },
    'py': (child, parts) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: parseToSpacing(parts)),
        child: child,
      );
    },
    'pb': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(bottom: parseToSpacing(parts)),
        child: child,
      );
    },
    'pt': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(top: parseToSpacing(parts)),
        child: child,
      );
    },
    'pl': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(left: parseToSpacing(parts)),
        child: child,
      );
    },
    'pr': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(right: parseToSpacing(parts)),
        child: child,
      );
    },
    // endregion

    // region Margin

    'm': (child, parts) {
      return Padding(
        padding: EdgeInsets.all(parseToSpacing(parts)),
        child: child,
      );
    },
    'mx': (child, parts) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: parseToSpacing(parts)),
        child: child,
      );
    },
    'my': (child, parts) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: parseToSpacing(parts)),
        child: child,
      );
    },
    'mb': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(bottom: parseToSpacing(parts)),
        child: child,
      );
    },
    'mt': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(top: parseToSpacing(parts)),
        child: child,
      );
    },
    'ml': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(left: parseToSpacing(parts)),
        child: child,
      );
    },
    'mr': (child, parts) {
      return Padding(
        padding: EdgeInsets.only(right: parseToSpacing(parts)),
        child: child,
      );
    },
    // endregion
  };

  // assumes list already validated and first part removed
  static double parseToSpacing(List<String> parts) {
    final valueStr = parts.first;
    //TODO:KB 15/11/2024 handle custom values in [] brackets, e.g. [24px]

    return double.parse(valueStr) * spacingMultiplier;
  }

  Widget parse(String className, List<Widget> children) {
    final classes = className.split(' ');

    if (classes.contains('hidden')) {
      return const SizedBox.shrink();
    }

    // Group classes by their type
    final classGroups = ClassGroups.fromClasses(classes);

    // Configure the layout first by processing all layout classes together
    Widget child = _buildFlexLayout(classGroups.layout, children);

    // Apply remaining classes in order
    for (final c in classGroups.internalSpacing) {
      child = _applyClass(c, child);
    }

    child = _applyVisualClasses(classGroups.visual, child);

    // Size the box before applying external spacing
    child = _applySizeClasses(classGroups.size, child);

    for (final c in classGroups.margin) {
      child = _applyClass(c, child);
    }

    return child;
  }

  Widget _applyVisualClasses(List<String> cs, Widget child) {
    if (cs.isEmpty) return child;

    Color? bgColor;
    BorderRadius borderRadius = BorderRadius.zero;
    for (final c in cs) {
      final parts = c.split('-');
      final key = parts[0];

      if (key == 'bg') {
        bgColor = _colorFrom(parts.sublist(1));
      }

      // Handles multiple radius classes
      // e.g. rounded-tl-md rounded-br-lg
      // NOTE:KB 24/11/2024 full doesn't work with multiple classes
      // e.g. rounded-t-full rounded-lg
      // after full is applied, the rest are ignored
      // this appears to be an issue in flutter itself
      if (key == 'rounded') {
        final nextRadius = _borderRadiusFrom(parts.sublist(1));
        dpl('nextRadius: $nextRadius');
        borderRadius = borderRadius.copyWith(
          topLeft:
              nextRadius.topLeft == Radius.zero ? null : nextRadius.topLeft,
          topRight:
              nextRadius.topRight == Radius.zero ? null : nextRadius.topRight,
          bottomRight: nextRadius.bottomRight == Radius.zero
              ? null
              : nextRadius.bottomRight,
          bottomLeft: nextRadius.bottomLeft == Radius.zero
              ? null
              : nextRadius.bottomLeft,
        );
      }
    }

    dpl('borderRadius: $borderRadius');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  Color? _colorFrom(List<String> parts) {
    final colorName = parts[0];
    switch (colorName) {
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'black':
        return const Color(0xFF000000);
      default:
        final colorRange = colors[colorName];
        if (colorRange == null) {
          dpl('Unknown color: $colorName');
          return null;
        }

        String? colorVariantName;
        if (parts.length > 1) {
          colorVariantName = parts[1];
        }

        if (colorVariantName == null) {
          dpl('No color variant specified for $colorName');
          return null;
        }

        final int? colorVariant = int.tryParse(colorVariantName);
        if (colorVariant == null) {
          dpl('Invalid color variant specified for $colorName: $colorVariantName');
          return null;
        }

        final color = colorRange[colorVariant];
        if (color == null) {
          dpl('Unknown color variant $colorVariant for $colorName');
        }
        return color;
    }
  }

  BorderRadius _borderRadiusFrom(List<String> parts) {
    if (parts.isEmpty) {
      return const BorderRadius.all(
        Radius.circular(spacingMultiplier),
      );
    }

    if (parts.length == 1) {
      // first part could be a size class or a specific edge / corner
      final radius = _radiusForSizeClass(parts.first);
      if (radius != null) {
        return BorderRadius.circular(radius);
      }
    }

    // e.g. tl || tl-md

    double? topLeft;
    double? topRight;
    double? bottomRight;
    double? bottomLeft;

    switch (parts.first) {
      // rounded-t-{size} - Top corners
      case 't':
        topLeft = topRight = _radiusForSizeClass(parts[1]);
        break;
      // rounded-r-{size} - Right corners
      case 'r':
        topRight = bottomRight = _radiusForSizeClass(parts[1]);
        break;
      // rounded-b-{size} - Bottom corners
      case 'b':
        bottomRight = bottomLeft = _radiusForSizeClass(parts[1]);
        break;
      // rounded-l-{size} - Left corners
      case 'l':
        bottomLeft = topLeft = _radiusForSizeClass(parts[1]);
        break;

      // rounded-tl-{size} - Top left corner
      case 'tl':
        topLeft = _radiusForSizeClass(parts[1]);
        break;
      // rounded-tr-{size} - Top right corner
      case 'tr':
        topRight = _radiusForSizeClass(parts[1]);
        break;
      // rounded-br-{size} - Bottom right corner
      case 'br':
        bottomRight = _radiusForSizeClass(parts[1]);
        break;
      // rounded-bl-{size} - Bottom left corner
      case 'bl':
        bottomLeft = _radiusForSizeClass(parts[1]);
        break;
      default:
        dpl('Unknown corner: ${parts.first}');
        return BorderRadius.zero;
    }

    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
    );
  }

  // Where {size} can be any of:
  //
  // none
  // sm (0.125rem / 2px)
  // DEFAULT (0.25rem / 4px)
  // md (0.375rem / 6px)
  // lg (0.5rem / 8px)
  // xl (0.75rem / 12px)
  // 2xl (1rem / 16px)
  // 3xl (1.5rem / 24px)
  // full (9999px)
  double? _radiusForSizeClass(String sizeClass) {
    return switch (sizeClass) {
      'sm' => spacingMultiplier,
      'md' => spacingMultiplier * 1.5,
      'lg' => spacingMultiplier * 2,
      'xl' => spacingMultiplier * 3,
      '2xl' => spacingMultiplier * 4,
      '3xl' => spacingMultiplier * 6,
      'full' => 9999.0,
      'none' => 0.0,
      _ => null,
    };
  }

  Widget _applySizeClasses(List<String> cs, Widget child) {
    if (cs.isEmpty) return child;

    // TODO:KB 15/11/2024 handle custom values in [] brackets, e.g. [24px]

    double? width;
    double? height;

    for (final c in cs) {
      final parts = c.split('-');
      if (parts.length == 1) continue;

      final key = parts[0];
      final value = parts[1];

      if (key == 'w') {
        // handle full width
        if (value == 'full') {
          width = double.infinity;
        } else {
          width = double.tryParse(value);
        }
      } else if (key == 'h') {
        if (value == 'full') {
          height = double.infinity;
        } else {
          height = double.tryParse(value);
        }
      }
    }

    if (width != null) {
      width *= spacingMultiplier;
    }

    if (height != null) {
      height *= spacingMultiplier;
    }

    // dpl('width: $width, height: $height');

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }

  Widget _applyClass(String className, Widget child) {
    final parts = className.split('-');
    if (parts.length == 1) return child;

    final key = parts[0];
    final sublist = parts.sublist(1);
    if (sublist.isEmpty) return child;

    final fun = classNameLookup[key];
    if (fun == null) {
      dpl('Unknown class: $key');
      if (kDebugMode) {
        throw FWUnknownClassException('Unknown class: $key');
      }
      return child;
    }

    return fun(child, sublist);
  }

  Widget _buildFlexLayout(
    List<String> layoutClasses,
    List<Widget> children,
  ) {
    dpl('layoutClasses: $layoutClasses');

    final axis = findValueForClass(
      layoutClasses,
      ClassGroups.axis,
      Axis.horizontal,
    );

    return Flex(
      direction: axis,
      mainAxisAlignment: findValueForClass(
        layoutClasses,
        ClassGroups.mainAxisAlignment,
        MainAxisAlignment.start,
      ),
      mainAxisSize: findValueForClass(
        layoutClasses,
        ClassGroups.mainAxisSize,
        MainAxisSize.max,
      ),
      crossAxisAlignment: findValueForClass(
        layoutClasses,
        ClassGroups.crossAxisAlignment,
        CrossAxisAlignment.center,
      ),
      verticalDirection: findValueForClass(
        layoutClasses,
        ClassGroups.verticalDirection,
        VerticalDirection.down,
      ),
      children: addGaps(
        children,
        layoutClasses,
        axis,
      ),
    );
  }
}

List<Widget> addGaps(
  List<Widget> children,
  List<String> classes,
  Axis axis,
) {
  final gaps = classes.where((c) => c.startsWith('gap-')).toList();
  if (gaps.isEmpty) return children;

  final gap = gaps.first;
  final parts = gap.split('-');
  if (parts.length != 2) return children;

  var gapSize = double.tryParse(parts[1]);
  if (gapSize == null) return children;

  gapSize *= ClassParser.spacingMultiplier;
  final gapWidget = axis == Axis.horizontal
      ? SizedBox(width: gapSize)
      : SizedBox(height: gapSize);

  final newChildren = <Widget>[];

  for (var i = 0; i < children.length; i++) {
    newChildren.add(children[i]);
    if (i < children.length - 1) {
      newChildren.add(gapWidget);
    }
  }

  return newChildren;
}

T findValueForClass<T>(
  List<String> classNames,
  Map<String, T> lookup,
  T defaultValue,
) {
  for (final className in classNames) {
    final value = lookup[className];
    if (value != null) {
      return value;
    }
  }

  return defaultValue;
}
