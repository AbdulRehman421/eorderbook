import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Utils {
  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  static String getTimestamp() {
    var time =
    ((DateTime.now().millisecondsSinceEpoch) / 1000).toStringAsFixed(0);
    return time;
  }

  static int generateInvoiceId(String lastId) {
    DateTime now = DateTime.now();
    var year = now.year.toString().substring(2, 4);
    var month = now.month.toString();
    var day = now.day.toString();

    if (int.parse(day) < 10) {
      day = "0$day";
    }

    if (int.parse(month) < 10) {
      month = "0$month";
    }

    if (int.parse(lastId) < 10) {
      lastId = "000$lastId";
    } else if (int.parse(lastId) < 100) {
      lastId = "00$lastId";
    } else if (int.parse(lastId) < 1000) {
      lastId = "0$lastId";
    }

    return int.parse(year + month.toString() + day.toString() + (lastId).toString());
  }


  static String makeInvoice(now,id){
    String formattedDate = DateFormat('ddMM').format(now);
    debugPrint(formattedDate); // Output: 0805
    String formattedNumber = id.toString().padLeft(3, '0');
    debugPrint(formattedNumber); // Output: 030
    return formattedDate+formattedNumber;
  }

  static showLoaderDialog(BuildContext context, title, subtitle) {
    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
      content: WillPopScope(
        onWillPop: () => Future.value(true),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator()),
                const SizedBox(
                  width: 10,
                ),
                Container(
                    margin: const EdgeInsets.only(left: 7), child: Text(subtitle)),
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

}

