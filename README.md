# pact_consumer_dart

[![Pub](https://img.shields.io/pub/v/pact_consumer_dart.svg)](https://pub.dartlang.org/packages/pact_consumer_dart)
[![documentation](https://img.shields.io/badge/Documentation-pact_consumer_dart-blue.svg)](https://www.dartdocs.org/documentation/pact_consumer_dart/latest/)
[![Build Status](https://travis-ci.org/thomaslevans-wf/pact_consumer_dart.svg?branch=master)](https://travis-ci.org/thomaslevans-wf/pact_consumer_dart)
[![codecov](https://codecov.io/gh/thomaslevans-wf/pact_consumer_dart/branch/master/graph/badge.svg)](https://codecov.io/gh/thomaslevans-wf/pact_consumer_dart)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

Dart Pact Consumer Library
An implementation of the Pact Consumer library for Dart. A 'How to Contribute' section will be up soon with specific guidelines on contributing. Feel free to open issues for any bugs or features requests.

## [The Pact Gem](https://github.com/bethesque/pact-mock_service)
The consumer library allows for interaction with the Pact service via a Dart ISL. In order for the library to be utilized either the gem must be running locally, or via docker.
### Running Pact from gem
_Note: Ruby v2.2.2 is required at a minimum._
```
$ gem install pact-mock_service
$ pact-mock-service start -p 1234
```

### Running Pact from docker
There is a docker image available to run [here](https://github.com/madkom/docker/tree/master/pact-mock-service) as opposed to running the gem locally.

_Note: This assumes you at least have docker available_

```
$ docker run -d -p 127.0.0.1:1234:1234 -v /tmp/log:/var/log/pacto -v /tmp/contracts:/opt/contracts madkom/pact-mock-service
```

## Pact Consumer API
At the core of the consumer library is the concept of interactions. Interactions are the building blocks of the contract between the Provider and the Consumer of a service. An interaction can be decomposed using a BDD style to the following statement.

> __Given__ some Provider's state, and a high level description of the interaction.
>
> __When__ the Consumer has issued the request, X.
>
> __Then__ the Provider will send the response, Y.

### Creating an instance of the PactMockService
The class constructor for PactMockService accepts a Map of options which, at a minimum, require a port, consumer name, and provider name. Additional properties that can be passed are:
- host := The host that the Pact service is running on, defaults to `127.0.0.1`
- dir := The directory in which to write the Pact files, defaults to `/pacts`
```
PactMockService mockService = new PactMockService({
  'consumer': 'PactConsumerDart',
  'provider': 'pact-mock-service',
  'port': '1234'
});
```
### Resetting the Current Session
You will want to clear out any interactions in between tests and/or test suites. Once you have an instance of PactMockService, simply call `resetSession` to delete any interactions setup on the current Pact service.
```
mockService.resetSession();
```
### Staging an Interaction
Declaring, or staging, an interaction follows the same BDD style highlighted above.

```
mockService
  .given('a request for the resource coal', providerState: 'the resource coal exists')
  .when('GET', '/resource/coal', headers: {
    'Accept': 'application/json'
  })
  .then(200, headers: {'Content-Type': 'application/json'}, body: {'resource':'coal'});
```
_Note: The optional param `providerState` passed to given should be omitted when there is no setup required in the state of the provider for the interaction_

### Setting up an Interaction
Once an interaction has been staged we can setup the Pact service to use the interaction.
```
mockService.setup();
```
Now the interaction has been dispatched to the Pact service, allowing the service to play the part of the Provider.
### Testing an Interaction
For every valid interaction the Pact service receives it will setup the necessary routes and handlers to receive the request defined in the interaction. Whenever Pact receives a request that matches an interaction, it will give the response defined in the interaction. A simple test of this may look like:
```
var res = await Http.get('http://localhost:1234/resource/coal');
expect(res.status, equals(200));
expect(res.body.asJson(), equals({'resource':'coal'}));
```

### Verifying and writing the Pact file
For any given interaction received by Pact, the interaction remains unverified until the matching request is received. All interactions must be verified before Pact can write the Contract as a Pact file.
```
mockService.verifyAndWrite();
```
This will write out all verified interactions as JSON, which will appear in the `/pact` directory by default.


## Flexible Matching
pact_consumer_dart supports [Flexible Matching](http://docs.pact.io/documentation/matching.html) according to the Pact Specification 2.0.0, read the specification docs provided by Pact for deeper understanding and usage.


## Notes and Helpful Links
pact_consumer_dart leverages w_transport in order to be platform agnostic. This means that this library can be used to write contract tests, regardless if the Consumer is client or server. This benefit does not come without added configuration. Thus when using pact_consumer_dart it is necessary to configure w_transport for the given consumer's platform.
- [Pact.io](http://docs.pact.io/)
- [w_transport](https://www.dartdocs.org/documentation/w_transport/2.9.2/index.html)
