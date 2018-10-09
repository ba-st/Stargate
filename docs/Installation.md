# Installation

## Basic Installation

You can load **Stargate** evaluating:
```smalltalk
Metacello new
	baseline: 'Stargate';
	repository: 'github://ba-st/Stargate:master/source';
	load.
```
>  Change `master` to some released version if you want a pinned version

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
