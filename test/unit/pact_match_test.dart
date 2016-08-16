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

import 'package:test/test.dart';

import 'package:pact_consumer_dart/src/pact_match.dart';

main() {
  group('PactMatch', () {
    var somethingLike = PactMatch.somethingLike;
    var term = PactMatch.term;
    var eachLike = PactMatch.eachLike;

    group('term', () {
      var createTheTerm = (badArg) {
        return () {
          term(badArg);
        };
      };

      group('when provided a term', () {
        test('should return a serialized Ruby object', () {
          var expected = {
            'json_class': 'Pact::Term',
            'data': {
              'generate': 'myawesomeword',
              'matcher': {'json_class': 'Regexp', 'o': 0, 's': '\\w+'}
            }
          };

          var match = term({'generate': 'myawesomeword', 'matcher': '\\w+'});

          expect(match, equals(expected));
        });
      });

      group('when no term is provided', () {
        test('should throw an Exception', () {
          expect(term, throws);
        });
      });

      group('when an invlid term is provided', () {
        test('should throw an Exception', () {
          expect(createTheTerm({}), throws);
          expect(createTheTerm({'generate': 'foo'}), throws);
          expect(createTheTerm({'matcher': '\\w+'}), throws);
        });
      });
    });

    group('somethingLike', () {
      group('when provided a value', () {
        test('should return a serialized Ruby object', () {
          var expected = {
            'json_class': 'Pact::SomethingLike',
            'contents': 'myspecialvalue'
          };

          var match = somethingLike('myspecialvalue');

          expect(match, equals(expected));
        });
      });

      group('when not provided with a valid value', () {
        var createTheValue = (badArg) {
          return () {
            somethingLike(badArg);
          };
        };

        group('when no value is provided', () {
          test('should throw an Exception', () {
            expect(createTheValue(null), throws);
          });
        });

        group('when an invalid value is provided', () {
          test('should throw an Exception', () {
            expect(createTheValue(() {}), throws);
          });
        });
      });
    });

    group('eachLike', () {
      group('when content is null', () {
        test('should provide null as content', () {
          var expected = {
            'json_class': 'Pact::ArrayLike',
            'contents': null,
            'min': 1
          };

          var match = eachLike(null, {'min': 1});

          expect(match, equals(expected));
        });
      });

      group('when options.min is invalid', () {
        var createTheMin = (badArg) {
          return () {
            eachLike(badArg.first, badArg.last);
          };
        };

        test('should throw an Exception', () {
          expect(
              createTheMin([
                {'a': 1},
                {'min': 0}
              ]),
              throws);
          expect(
              createTheMin([
                {'a': 1},
                {'min': null}
              ]),
              throws);
        });
      });

      group('when an array is provided', () {
        test('should provide the array as contents', () {
          var expected = {
            'json_class': 'Pact::ArrayLike',
            'contents': [1, 2, 3],
            'min': 1
          };

          var match = eachLike([1, 2, 3], {'min': 1});

          expect(match, equals(expected));
        });
      });

      group('when a value is provided', () {
        test('should add the value in contents', () {
          var expected = {
            'json_class': 'Pact::ArrayLike',
            'contents': 'test',
            'min': 1
          };

          var match = eachLike('test', {'min': 1});

          expect(match, equals(expected));
        });
      });

      group('when the content has Pact.Matchers', () {
        group('of type somethingLike', () {
          test('should nest somethingLike correctly', () {
            var expected = {
              'json_class': 'Pact::ArrayLike',
              'contents': {
                'id': {'json_class': 'Pact::SomethingLike', 'contents': 10}
              },
              'min': 1
            };

            var match = eachLike({'id': somethingLike(10)}, {'min': 1});

            expect(match, equals(expected));
          });
        });

        group('of type term', () {
          test('should nest term correctly', () {
            var expected = {
              'json_class': 'Pact::ArrayLike',
              'contents': {
                'colour': {
                  'json_class': 'Pact::Term',
                  'data': {
                    'generate': 'red',
                    'matcher': {
                      'json_class': 'Regexp',
                      'o': 0,
                      's': 'red|green'
                    }
                  }
                }
              },
              'min': 1
            };

            var match = eachLike({
              'colour': term({'generate': 'red', 'matcher': 'red|green'})
            }, {
              'min': 1
            });

            expect(match, equals(expected));
          });
        });

        group('of type eachLike', () {
          test('should nest eachLike in contents', () {
            var expected = {
              'json_class': 'Pact::ArrayLike',
              'contents': {
                'json_class': 'Pact::ArrayLike',
                'contents': 'blue',
                'min': 1
              },
              'min': 1
            };

            var match = eachLike(eachLike('blue', {'min': 1}), {'min': 1});

            expect(match, equals(expected));
          });
        });

        group('complex object with multiple Pact.Matchers', () {
          test('should nest objects correctly', () {
            var expected = {
              'json_class': 'Pact::ArrayLike',
              'contents': {
                'json_class': 'Pact::ArrayLike',
                'contents': {
                  'size': {'json_class': 'Pact::SomethingLike', 'contents': 10},
                  'colour': {
                    'json_class': 'Pact::Term',
                    'data': {
                      'generate': 'red',
                      'matcher': {
                        'json_class': 'Regexp',
                        'o': 0,
                        's': 'red|green|blue'
                      }
                    }
                  },
                  'tag': {
                    'json_class': 'Pact::ArrayLike',
                    'contents': [
                      {
                        'json_class': 'Pact::SomethingLike',
                        'contents': 'jumper'
                      },
                      {'json_class': 'Pact::SomethingLike', 'contents': 'shirt'}
                    ],
                    'min': 2
                  }
                },
                'min': 1
              },
              'min': 1
            };

            var match = eachLike(
                eachLike({
                  'size': somethingLike(10),
                  'colour':
                      term({'generate': 'red', 'matcher': 'red|green|blue'}),
                  'tag': eachLike(
                      [somethingLike('jumper'), somethingLike('shirt')],
                      {'min': 2})
                }, {
                  'min': 1
                }),
                {'min': 1});

            expect(match, equals(expected));
          });
        });
      });

      group('when options.min is not provided', () {
        test('should default to a min of 1', () {
          var expected = {
            'json_class': 'Pact::ArrayLike',
            'contents': {'a': 1},
            'min': 1
          };

          var match = eachLike({'a': 1});

          expect(match, equals(expected));
        });
      });

      group('when a options.min is provided', () {
        test('should provide the object as contents', () {
          var expected = {
            'json_class': 'Pact::ArrayLike',
            'contents': {'a': 1},
            'min': 3
          };

          var match = eachLike({'a': 1}, {'min': 3});

          expect(match, equals(expected));
        });
      });
    });
  });
}
