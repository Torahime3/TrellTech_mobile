import 'package:intl/intl.dart';

String trelloDate(String dateStr) {
  DateTime date = DateTime.parse(dateStr).toLocal();
  return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(date);
}

extension FormattedDate on DateTime {
  String formattedDate() {
    return DateFormat('dd MMMM yyyy, hh:mm a')
        .format(this); // Customize date format as needed
  }
}
