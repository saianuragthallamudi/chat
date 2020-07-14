import 'dart:convert';
import 'package:http/http.dart';

class notification {
  static final Client client = Client();
  static const String apitoken =
      'AAAAjufMReg:APA91bEsh9aDlIRCfjKRvu_NBjV-J-77cSQX-SGs9sxyDjpsQ38rI93BJWOEe7TLhQBJorSrzpjTFb2oREnZDjTAR2pHxgWpJV81CJKhUhgk0zDy2AEUzSkVR-dY2VhNlOo8ntYOs46T';

  static Future<Response> sendto({String title, String body, String token,String value}) {
    print('entered function');
    print(token);
    return client.post('https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          "notification": {"body": "$body", "title": "$title"},
          "priority": "high",
          "data": {
            "body": "$body",
           "title": "$title",
            "value": "$value",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id": "1",
            "status": "done"
          },
          "to": "/topics/$token",
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$apitoken'
        });
  }
}
