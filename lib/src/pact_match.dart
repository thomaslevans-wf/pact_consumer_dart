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

class PactMatch {
  static Map term(Map term) {
    if (term == null ||
        !term.containsKey('generate') ||
        !term.containsKey('matcher')) {
      throw new Exception(
          'Exception creating a Pact Term. Please provide an object containing \'generate\' and \'matcher\' properties');
    }

    return {
      'json_class': 'Pact::Term',
      'data': {
        'generate': term['generate'],
        'matcher': {'json_class': 'Regexp', 'o': 0, 's': term['matcher']}
      }
    };
  }

  static Map eachLike(dynamic content, [Map options]) {
    if (options is Map && (options['min'] == null || options['min'] < 1)) {
      throw new Exception(
          'Exception creating a Pact eachLike. Please provide options.min that is > 1');
    }

    return {
      'json_class': 'Pact::ArrayLike',
      'contents': content,
      'min': (options == null) ? 1 : options['min']
    };
  }

  static Map somethingLike(dynamic value) {
    if (value == null) {
      throw new Exception(
          'Exception creating a Pact somethingLike PactMatch. Value cannot be null');
    }

    if (value is Function) {
      throw new Exception(
          'Exception creating a Pact somethingLike PactMatch. Value cannot be a function');
    }

    return {'json_class': 'Pact::SomethingLike', 'contents': value};
  }
}
