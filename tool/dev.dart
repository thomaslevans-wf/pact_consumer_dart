library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  // https://github.com/Workiva/dart_dev

  // Perform task configuration here as necessary.

  // Available task configurations:
  // config.analyze
  // config.copyLicense
  // config.coverage
  // config.docs
  // config.examples
  // config.format
  // config.test

  config.analyze.entryPoints = [
    'lib/',
    'test/unit/',
    'test/integration',
    'tool/'
  ];

  config.coverage..pubServe = true;

  config.copyLicense.directories = ['lib/', 'test/'];

  config.format.paths = ['lib/', 'test/', 'tool'];

  config.test
    ..integrationTests = ['test/integration/generated_runner_test.dart']
    ..unitTests = ['test/unit/generated_runner_test.dart']
    ..platforms = ['vm'];

  await dev(args);
}
