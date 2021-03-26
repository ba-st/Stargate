# Installation

## Basic Installation

You can load **Stargate** evaluating:
```smalltalk
Metacello new
	baseline: 'Stargate';
	repository: 'github://ba-st/Stargate:release-candidate/source';
	load.
```
>  Change `release-candidate` to some released version if you want a pinned version

## Using as dependency

To include **Stargate** as part of your project, you should reference the package in your product baseline:

```smalltalk
setUpDependencies: spec

	spec
		baseline: 'Stargate'
			with: [ spec
				repository: 'github://ba-st/Stargate:v{XX}/source';
				loads: #('Deployment') ];
		import: 'Stargate'.
```
> Replace `{XX}` with the version you want to depend on

```smalltalk
baseline: spec

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
			spec package: 'My-Package' with: [ spec requires: #('Stargate') ] ]
```

## Provided groups

- `Deployment`: will load all the packages needed in a deployed application (including the operational plugins)
- `Core`: will load the minimal packages required in a deployed application (excluding operational plugins)
- `JSON-RPC`: will load the deployment support to integrate JSON-RPC calls under some endpoint in the RESTful API
- `HealthCheck`: will load the deployment support for the HealthCheck plugin
- `Metrics`: will load the deployment support for the Metrics plugin
- `Metrics-HTTP`: will load additional metrics for HTTP requests
- `Application-Control`: will load the deployment support for the Application Control plugin
- `Tests`: will load the test cases
- `Dependent-SUnit-Extensions`: will load the extensions to the SUnit framework
- `Tools`: will load the extensions to the SUnit framework and development tools (inspector and spotter extensions)
- `CI`: will load the packages checked by the continuous integration setup
- `Development`: will load all the needed packages to develop and contribute to the project
