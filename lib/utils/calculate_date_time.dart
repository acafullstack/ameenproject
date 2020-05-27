

import 'package:intl/intl.dart';

String returnMonth(String month) {
  var monthNo = 1;
  print("month ******* ${month}");
  try {
    monthNo = int.parse(month.substring(0,2));
    print("month no ******* ${monthNo}");
  } catch (e) {
    print(e);
  }
  //var month_no = int.parse(month.substring(8));
  switch(monthNo){
    case 1: return "JAN";
    case 2: return "Feb";
    case 3: return "Mar";
    case 4: return "Apr";
    case 5: return "May";
    case 6: return "Jun";
    case 7: return "Jul";
    case 8: return "Aug";
    case 9: return "Sep";
    case 10: return "Oct";
    case 11: return "Nov";
    case 12: return "Dec";
  }
  return "Jan";
}

String returnDate(String date) {
  var dateNumber = "01";
  try {
    dateNumber = date.substring(3,5);
  } catch (e) {
    print(e);
  }
  return dateNumber;
}

String returnFormattedDate(String date) {
  return DateFormat('mm/dd/yyyy').parse(date).toString();
}

int timeDateToLong(String dateTime) {
  DateFormat dateFormat = DateFormat("dd-MM-yyyy hh:mm");
  var estimatedTime = DateTime.now();
  var timeInInt = 0;
  try {
    estimatedTime = dateFormat.parse(dateTime);
    print("date time ${estimatedTime}");
    timeInInt = estimatedTime.millisecondsSinceEpoch;
  } catch(e) {
    print("date time ${e.toString()}");
  }
  return timeInInt;

}


