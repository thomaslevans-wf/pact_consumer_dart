import 'dart:async';
import 'dart:convert';
import 'package:w_transport/w_transport.dart';

class PactMockServiceRequests {
  static Map _headers = {
    'X-Pact-Mock-Service': 'true',
    'Content-Type': 'application/json'
  };

  static Future getVerification(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions/verification');
    return Http.get(uri, headers: _headers);
  }

  static Future postInteraction(Map interaction, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return Http.post(uri, body: JSON.encode(interaction), headers: _headers);
  }

  static Future postPact(dynamic pactDetails, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/pact');
    return Http.post(uri, body: JSON.encode(pactDetails), headers: _headers);
  }

  static Future deleteSession(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return Http.delete(uri, headers: _headers);
  }
}
