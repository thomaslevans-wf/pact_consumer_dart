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
