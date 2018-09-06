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
    accentColorBrightness: Brightness.dark,
  );

  /// Material Colors. Not supposed to change or delete. ONLY ADD.
  static Map<String, Map<String, dynamic>> coloredThemes = <String, Map<String, dynamic>>{
    'red': {
      'primarySwatch': Colors.red,
      'accentColor': Colors.redAccent.shade700,
    },
    'orange': {
      'primarySwatch': Colors.orange,
      'accentColor': Colors.orangeAccent.shade700,
    },
    'deepOrange': {
      'primarySwatch': Colors.deepOrange,
      'accentColor': Colors.deepOrangeAccent.shade700,
    },
    'amber': {
      'primarySwatch': Colors.amber,
      'accentColor': Colors.amberAccent.shade700,
    },
    'yellow': {
      'primarySwatch': Colors.yellow,
      'accentColor': Colors.yellowAccent.shade700,
    },
    'green': {
      'primarySwatch': Colors.green,
      'accentColor': Colors.greenAccent.shade700,
    },
    'lightGreen': {
      'primarySwatch': Colors.lightGreen,
      'accentColor': Colors.lightGreenAccent.shade700,
    },
    'teal': {
      'primarySwatch': Colors.teal,
      'accentColor': Colors.tealAccent.shade700,
    },
    'cyan': {
      'primarySwatch': Colors.cyan,
      'accentColor': Colors.cyanAccent.shade700,
    },
    'lightBlue': {
      'primarySwatch': Colors.lightBlue,
      'accentColor': Colors.lightBlueAccent.shade700,
    },
    'blue': {
      'primarySwatch': Colors.blue,
      'accentColor': Colors.blueAccent.shade700,
    },
    'indigo': {
      'primarySwatch': Colors.indigo,
      'accentColor': Colors.indigoAccent.shade700,
    },
    'purple': {
      'primarySwatch': Colors.purple,
      'accentColor': Colors.purpleAccent.shade700,
    },
    'deepPurple': {
      'primarySwatch': Colors.deepPurple,
      'accentColor': Colors.deepPurpleAccent.shade700,
    },
    'pink': {
      'primarySwatch': Colors.pink,
      'accentColor': Colors.pinkAccent.shade700,
    },
  };
}

class IssualTransitions {
  static PageRouteBuilder verticlaPageTransition(
      Function(BuildContext, Animation<double>, Animation<double>) pageBuilder) {
    return new PageRouteBuilder(
      pageBuilder: pageBuilder,
      transitionsBuilder: (context, ani1_, ani2, Widget child) {
        var ani1 = CurvedAnimation(curve: Curves.easeOut, parent: ani1_);
        return new FadeTransition(
          opacity: ani1,
          child: new SlideTransition(
            position: Tween(begin: Offset(0.0, 0.2), end: Offset(0.0, 0.0)).animate(ani1),
            child: child,
          ),
        );
      },
    );
  }
}

class IssualMisc {
  static String getReadableTimeRepresentation(DateTime time, [bool withPrefix = false]) {
    if (time == null) return 'at unknown time';
    Duration timeFromNow = DateTime.now().difference(time);
    if (timeFromNow.compareTo(Duration(minutes: 2)) < 0) {
      return 'just now';
    } else if (timeFromNow.compareTo(Duration(minutes: 90)) < 0) {
      return '${withPrefix ? "at " : ""}${timeFromNow.inMinutes + timeFromNow.inHours * 60} minutes ago';
    } else if (timeFromNow.compareTo(Duration(days: 1)) < 0) {
      return '${withPrefix ? "at " : ""}${timeFromNow.inHours} hours ago';
    } else {
      return '${withPrefix ? "at " : ""}${time.year}-${time.month}-${time.day}';
    }
  }

  static Color getColorForState(BuildContext context, String state) {
    final theme = Theme.of(context);
    switch (state) {
      case 'closed':
      case 'finished':
        return theme.disabledColor;
        break;
      case 'active':
      case 'pending':
        return theme.accentColor;
        break;
      case 'open':
      default:
        return theme.primaryColor;
        break;
    }
  }

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

  static Color getColorForStateDesaturated(BuildContext context, String state) {
    final theme = Theme.of(context);
    switch (state) {
      case 'closed':
      case 'finished':
        return theme.disabledColor;
        break;
      case 'open':
      case 'active':
      case 'pending':
      default:
        return theme.textTheme.body1.color;
        break;
    }
  }

  static const stateIcons = <String, IconData>{
    'open': Icons.radio_button_unchecked,
    'closed': Icons.check_circle_outline,
    'pending': Icons.access_time,
    'active': Icons.data_usage,
    'canceled': Icons.remove_circle_outline,
  };
}
