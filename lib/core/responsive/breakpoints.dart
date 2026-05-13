/// Layout breakpoints aligned with Material 3 width conventions.
enum AppBreakpoint {
  compact(0),
  medium(600),
  expanded(840),
  large(1200);

  const AppBreakpoint(this.minWidth);
  final double minWidth;

  static AppBreakpoint fromWidth(double width) {
    if (width >= large.minWidth) return large;
    if (width >= expanded.minWidth) return expanded;
    if (width >= medium.minWidth) return medium;
    return compact;
  }
}
