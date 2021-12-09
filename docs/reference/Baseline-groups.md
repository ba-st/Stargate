# Baseline Groups

Stargate includes the following groups in its Baseline that can be used as
loading targets:

- `Core` will load the minimal required packages to support RESTful APIs
- `HealthCheck` will load the packages needed to support the [Health check plugin](HealthCheck.md)
- `Metrics`  will load the packages needed to support the [Metrics plugin](Metrics.md)
- `Application-Control`  will load the packages needed to support the
  [Application Control plugin](ApplicationControl.md)
- `Application-Info`  will load the packages needed to support the
  [Application Info plugin](ApplicationInfo.md)
- `Application-Configuration`  will load the packages needed to support the
  [Application Configuration plugin](ApplicationConfiguration.md)
- `Loggers`  will load the packages needed to support the [Loggers  plugin](Loggers.md)
- `JSON-RPC`  will load the packages needed to support JSON RPC APIs.
- `Deployment` will load all the packages needed in a deployed application,
  which in this case correspond to `Core` + `HealthCheck` + `Metrics` +
  `Application-Control` + `Application-Info` + `Application-Configuration` +
  `Loggers`
- `Examples` will load some example API controllers
- `Tests` will load the test cases
- `Tools` will load tooling extensions
- `Dependent-SUnit-Extensions` will load extensions to SUnit for testing API clients
- `CI` is the group loaded in the continuous integration setup, in this
  particular case it is the same as `Tests`
- `Development` will load all the needed packages to develop and contribute to
   the project
