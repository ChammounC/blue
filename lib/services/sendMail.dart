import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future sendEmail({
  required String name,
  required String email,
  required String subject,
  required String number,
  required String message,
}) async {

  final serviceId = dotenv.get('MAIL_SERVICE_ID');
  final templateId = dotenv.get('MAIL_TEMPLATE_ID');
  final userId =dotenv.get('MAIL_USER_ID');

  final url = Uri.parse(dotenv.get('MAIL_URL'));
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'user_name': name,
        'user_email': email,
        'user_number':number,
        'user_subject': subject,
        'user_message': message,
      },
    }),
  );

  if (kDebugMode) {
    print(response.body);
  }
}