import 'package:intl/intl.dart';

String trelloDate(DateTime date) {
  return date.toUtc().toIso8601String();
}

extension FormattedDate on DateTime {
  String displayedDate() {
    return DateFormat('dd MMMM yyyy, hh:mm a')
        .format(this); // Customize date format as needed
  }
}
