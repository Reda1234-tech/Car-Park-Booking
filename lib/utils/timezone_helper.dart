import 'package:timezone/data/latest_all.dart' as tz;

class TimezoneHelper {
  static Future<void> initializeTimezones() async {
    tz.initializeTimeZones();
  }
}
