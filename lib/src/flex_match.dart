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

class FlexMatch {
  /// Returns a serialized matcher for a term using the [matcher] and [generate].
  ///
  /// [matcher] := Ruby Regular Expression that should be used for matching
  /// [generate] := The test oracle/value that will be used to generate the term.
  ///
  /// Throws a [StateError] if either [matcher] or [generate] are empty Strings.
  static Map term(String generate, String matcher) {
    if (generate.isEmpty || matcher.isEmpty) {
      throw new StateError(
          'creating a Pact Term. Please provide an object containing \'generate\' and \'matcher\' properties');
    }

    return {
      'json_class': 'Pact::Term',
      'data': {
        'generate': generate,
        'matcher': {'json_class': 'Regexp', 'o': 0, 's': matcher}
      }
    };
  }

  /// Returns a serialized matcher for an array of [content].
  ///
  /// [min] := minimum number of members the array should have.
  ///
  /// Throws a [StateError] if min is less than 1.
  static Map eachLike(dynamic content, {int min}) {
    if (min != null && min < 1) {
      throw new StateError(
          'creating a Pact eachLike. `min` must be greater than or equal to 1.');
    }

    return {
      'json_class': 'Pact::ArrayLike',
      'contents': content,
      'min': (min != null) ? min : 1
    };
  }

  /// Returns a serialized matcher for a type of [value]
  ///
  /// Throws a [StateError] if [value] is a Function or null.
  static Map somethingLike(dynamic value) {
    if (value == null) {
      throw new StateError(
          'creating a Pact somethingLike FlexMatch. Value cannot be null');
    }

    if (value is Function) {
      throw new StateError(
          'creating a Pact somethingLike FlexMatch. Value cannot be a function');
    }

    return {'json_class': 'Pact::SomethingLike', 'contents': value};
  }
}
