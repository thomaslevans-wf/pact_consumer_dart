// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'package:w_transport/w_transport.dart';

/// Encapsulates the requests made by [PactMockService] client in order to leverage the Pact Service.
class PactMockServiceRequests {

  static Map<String,String> _headers = {
    'X-Pact-Mock-Service': 'true',
    'Content-Type': 'application/json'
  };

  /// GETs the verification that all interactions have been exercised.
  static Future getVerification(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions/verification');
    return Http.get(uri, headers: _headers);
  }

  /// POSTs an interaction to the Pact Service, setting it up for Contract Testing.
  static Future postInteraction(Map interaction, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return Http.post(uri, body: jsonEncode(interaction), headers: _headers);
  }

  /// POSTs the details of the pact to the Pact Service for generating the Pact File.
  static Future postPact(dynamic pactDetails, String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/pact');
    return Http.post(uri, body: jsonEncode(pactDetails), headers: _headers);
  }

  /// DELETEs all interactions from the Pact Service.
  static Future deleteSession(String baseUrl) async {
    Uri uri = Uri.parse(baseUrl + '/interactions');
    return Http.delete(uri, headers: _headers);
  }
}
