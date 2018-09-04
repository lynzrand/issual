import 'package:flutter/material.dart';

class IssualColors {
  static Color lightColor = new Color(0xffffffff);
  static Color darkColor = new Color(0xff33373C);
  static Color darkColorRipple = new Color(0x4433373C);
  static MaterialColor primary = Colors.blueGrey;
  // static ColorSwatch lightSwatch = new ColorSwatch(primary, _swatch)

  static ThemeData issualMainTheme = new ThemeData(
    primarySwatch: primary,
    accentColor: primary.shade800,
    primaryColor: primary.shade50,
    scaffoldBackgroundColor: primary.shade50,
    brightness: Brightness.light,
  );

  static Map<String, ThemeData> coloredThemes = <String, ThemeData>{
    'red': ThemeData(
      primarySwatch: Colors.red,
      accentColor: Colors.redAccent,
    ),
    'blue': ThemeData(
      primarySwatch: Colors.blue,
      accentColor: Colors.blueAccent,
    ),
  };

  static TextStyle getTodoTextStyle(BuildContext ctx, String state) {
    TextStyle ts;
    switch (state) {
      case 'closed':
      case 'canceled':
        ts = TextStyle(
          color: Theme.of(ctx).disabledColor,
          decoration: TextDecoration.lineThrough,
        );
        break;
      case 'active':
      case 'pending':
        ts = TextStyle(
          color: Theme.of(ctx).accentColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'open':
      default:
        break;
    }
    return Theme.of(ctx).textTheme.body1.merge(ts);
  }
}
