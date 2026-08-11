import 'package:easy_localization/easy_localization.dart';
import 'package:ntp/ntp.dart';
import '../../cache/storage/cache_helper.dart' show SP;

class DateTimeHelper {
  //!======================GET NOW======================
  static Future<DateTime> get now async => await NTP.now();

  //!======================FORMAT DATE TIME LOCALIZED====
  static String formatFullDateTimeLocalized(
    String date, {
    bool withTime = true,
  }) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final contextLocale = SP.getAppLang();

    // Weekday and month names
    final List<String> arabicWeekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final List<String> englishWeekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final List<String> englishMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    String weekday;
    String month;
    if (contextLocale == 'ar') {
      weekday = arabicWeekdays[dateTime.weekday - 1];
      month = arabicMonths[dateTime.month - 1];
    } else {
      weekday = englishWeekdays[dateTime.weekday - 1];
      month = englishMonths[dateTime.month - 1];
    }

    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isAm = dateTime.hour < 12;

    String timePeriod;
    if (contextLocale == 'ar') {
      timePeriod = isAm ? 'ص' : 'م';
    } else {
      timePeriod = isAm ? 'AM' : 'PM';
    }
    final bool isToday =
        dateTime.year == DateTime.now().year &&
        dateTime.month == DateTime.now().month &&
        dateTime.day == DateTime.now().day;
    final String time = '$hour:$minute $timePeriod';
    final String dateString = isToday
        ? contextLocale == 'ar'
              ? 'اليوم'
              : 'Today'
        : withTime
        ? '$weekday، $day $month $year'
        : '$day $month $year';

    if (contextLocale == 'ar') {
      return withTime ? '$dateString ، الساعة $time' : dateString;
    } else {
      return withTime ? '$dateString ، $time' : dateString;
    }
  }

  //!======================TIME AGO FROM NOW======================
  static String timeAgoFromNow(String date) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final DateTime now = DateTime.now();
    Duration diff = now.difference(dateTime);
    if (diff.isNegative) diff = Duration.zero;

    final int years = diff.inDays ~/ 365;
    final int months = (diff.inDays % 365) ~/ 30;
    final int days = (diff.inDays % 365) % 30;
    final int hours = diff.inHours % 24;
    final int minutes = diff.inMinutes % 60;

    final List<String> parts = [];
    if (years > 0) parts.add('$years ${'date_time.year'.tr()}');
    if (months > 0) parts.add('$months ${'date_time.month'.tr()}');
    if (days > 0) {
      parts.add(
        '${days == 1 ? "" : days} ${days == 1 ? 'date_time.day'.tr() : 'date_time.days'.tr()}',
      );
    }
    if (hours > 0) {
      parts.add(
        '$hours ${hours == 1 ? 'date_time.hour'.tr() : 'date_time.hours'.tr()}',
      );
    }
    if (minutes > 0) {
      parts.add(
        '$minutes ${minutes == 1 ? 'date_time.minute'.tr() : 'date_time.minutes'.tr()}',
      );
    }

    if (parts.isEmpty) return 'date_time.just_now'.tr();
    return '${'date_time.from'.tr()} ${parts.join(' ${'date_time.and'.tr()}')}';
  }

  //!======================REFORMAT DATE TIME======================
  static String reformatDateTime(String date) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final int hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour == 0
        ? 12
        : dateTime.hour;
    final String period = dateTime.hour < 12
        ? 'date_time.am'.tr()
        : 'date_time.pm'.tr();

    return '${dateTime.toString().split(' ')[0].split('-').reversed.join('/')} '
        '_${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  //!======================REFORMAT DATE======================
  static String reformatDate(String date) {
    final DateTime dateTime = DateTime.parse(date).toLocal();

    return dateTime.toString().split(' ')[0].split('-').reversed.join('/');
  }

  //!======================REFORMAT DATE LOCALIZED======================
  static String reformatDateLocalized(String date, {String? locale}) {
    try {
      final DateTime dateTime = DateTime.parse(date).toLocal();
      final contextLocale = SP.getAppLang();
      final day = dateTime.day;
      final year = dateTime.year;

      final List<String> arabicMonths = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];

      final List<String> englishShortMonths = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      if (contextLocale.startsWith('ar')) {
        final month = arabicMonths[dateTime.month - 1];
        return '$day $month $year';
      } else {
        final month = englishShortMonths[dateTime.month - 1];
        return '$day $month $year';
      }
    } catch (_) {
      // Fallback to a simple yyyy-mm-dd -> dd/mm/yyyy format if parsing fails
      try {
        final parts = date.split(' ')[0].split('-');
        if (parts.length >= 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      } catch (_) {}
      return date;
    }
  }

  //!======================REFORMAT TIME REMAINING======================
  static String reformatTimeRemaining(
    String date, {
    bool showDays = true,
    bool showHours = true,
    bool showMinutes = true,
  }) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final DateTime now = DateTime.now();
    final Duration difference = dateTime.difference(now);
    int days = difference.inDays;
    int hours = difference.inHours.remainder(24);
    int minutes = difference.inMinutes.remainder(60);
    final List<String> parts = [];
    if (days > 0 && showDays) {
      if (hours > 0 && !showHours) {
        days += 1;
      }
      parts.add(
        "$days ${days == 1 || days == 2 ? "date_time.day".tr() : "date_time.days".tr()}",
      );
    }
    if (hours > 0 && showHours) {
      parts.add(
        "$hours ${hours == 1 || hours == 2 ? "date_time.hour".tr() : "date_time.hours".tr()}",
      );
    }
    if (minutes > 0 && showMinutes) {
      parts.add(
        "$minutes ${minutes == 1 || minutes == 2 ? "date_time.minute".tr() : "date_time.minutes".tr()}",
      );
    }
    return parts.join(' / ');
  }

  //!======================REFORMAT DAY REMAINING======================
  static String reformatDayRemaining(String endDate) {
    final DateTime end = DateTime.parse(endDate).toLocal();
    final DateTime now = DateTime.now();

    if (now.isAfter(end)) return '';

    final int days = end.difference(now).inDays;
    if (days <= 0) return '';

    final String dayWord = (days == 1 || days == 2)
        ? 'date_time.day'.tr()
        : 'date_time.days'.tr();
    return '( متبقي $days $dayWord)';
  }

  //!======================REFORMAT TIME LOCALIZED======================
  static String reformatTimeLocalized(String date, {String? locale}) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final contextLocale = SP.getAppLang();

    final int hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final bool isAm = dateTime.hour < 12;

    final String period = contextLocale.startsWith('ar')
        ? (isAm ? 'ص' : 'م')
        : (isAm ? 'AM' : 'PM');

    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  // //!======================FORMAT TO HIJRI AND GREGORIAN======================
  // static String formatToHijriAndGregorian(
  //   String date, {
  //   String locale = 'ar',
  // }) {
  //   final DateTime dateTime = DateTime.parse(date).toLocal();

  //   HijriCalendar.setLocal(locale);
  //   final HijriCalendar hijriDate = HijriCalendar.fromDate(dateTime);

  //   final String hijriString =
  //       '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ';

  //   final String gregorianString = DateFormat(
  //     'dd MMMM yyyy',
  //     locale,
  //   ).format(dateTime);

  //   return locale == 'ar'
  //       ? '$hijriString (الموافق $gregorianString م)'
  //       : '$hijriString ($gregorianString)';
  // }

  //!======================GET REMAINING DAYS======================
  static String getRemainingDays(String date) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final DateTime now = DateTime.now();
    final int days = dateTime.difference(now).inDays;

    if ([3, 4, 5, 6, 7, 8, 9, 10].contains(days)) {
      return '$days ${'date_time.days'.tr()}';
    } else if (days == 1) {
      return 'date_time.day'.tr();
    } else if (days == 2) {
      return 'date_time.two_days'.tr();
    } else {
      return '$days ${'date_time.day'.tr()}';
    }
  }

  //!======================GET REMAINING HOURS======================
  static String getRemainingHours(String date) {
    final DateTime dateTime = DateTime.parse(date).toLocal();
    final DateTime now = DateTime.now();
    final int hours = dateTime.difference(now).inHours;

    if ([3, 4, 5, 6, 7, 8, 9, 10].contains(hours)) {
      return '$hours ${'date_time.hours'.tr()}';
    } else if (hours == 1) {
      return 'date_time.hour'.tr();
    } else if (hours == 2) {
      return 'date_time.two_hours'.tr();
    } else {
      return '$hours ${'date_time.hour'.tr()}';
    }
  }
}
