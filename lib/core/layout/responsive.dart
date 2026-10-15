import 'package:flutter/widgets.dart';

/// Breakpoint lebar layar (§4.5 Claude.md): HP < 600dp, Tablet >= 600dp.
abstract final class Breakpoints {
  static const tablet = 600.0;
  static const wideTablet = 900.0;
}

bool isTabletWidth(double width) => width >= Breakpoints.tablet;

bool isTablet(BuildContext context) =>
    isTabletWidth(MediaQuery.sizeOf(context).width);

/// Jumlah kolom grid produk: 2 di HP, 3 di tablet, 4 di tablet lebar (>=900dp).
int productGridColumns(double width) {
  if (width >= Breakpoints.wideTablet) return 4;
  if (width >= Breakpoints.tablet) return 3;
  return 2;
}
