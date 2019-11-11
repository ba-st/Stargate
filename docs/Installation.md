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

In order to include **Stargate** as part of your project, you should reference the package in your product baseline:

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

- `Deployment` will load all the packages needed in a deployed application (including the operational plugins)
- `Core` will load the minimal packages required in a deployed application (excluding operational plugins)
- `HealthCheck` will load the deployment support for the HealthCheck plugin
- `Metrics` will load the deployment support for the Metrics plugin
- `Tests` will load the test cases
- `Dependent-SUnit-Extensions` will load the extensions to the SUnit framework
- `Tools` will load the extensions to the SUnit framework and development tools (inspector and spotter extensions)
- `CI` is the group loaded in the continuous integration setup
- `Development` will load all the needed packages to develop and contribute to the project
