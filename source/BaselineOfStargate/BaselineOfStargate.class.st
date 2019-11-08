Class {
	#name : #BaselineOfStargate,
	#superclass : #BaselineOf,
	#category : #BaselineOfStargate
}

{ #category : #baselines }
BaselineOfStargate >> baseline: spec [

	<baseline>
	spec
		for: #pharo
		do: [ self
				setUpDependencies: spec;
				setUpPackages: spec.
			spec
				group: 'CI' with: 'Tests';
				group: 'Examples' with: #('Deployment' 'Stargate-Examples');
				group: 'Tools' with: #('Teapot-Tools');
				group: 'Development' with: #('Tests' 'Tools')
			]
]

{ #category : #accessing }
BaselineOfStargate >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfStargate >> setUpDependencies: spec [

	spec
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v5/source' ];
		project: 'Buoy-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ];
		project: 'Buoy-SUnit' copyFrom: 'Buoy' with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Hyperspace' with: [ spec repository: 'github://ba-st/Hyperspace:v1/source' ];
		project: 'Hyperspace-Deployment' copyFrom: 'Hyperspace' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'Teapot' with: [ spec repository: 'github://zeroflag/Teapot:v2.6.0/source' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ];
		project: 'Teapot-Tools' copyFrom: 'Teapot' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'JSONWebToken' with: [ spec repository: 'github://ba-st/JSONWebToken:master/source' ];
		project: 'JSONWebToken-Deployment'
			copyFrom: 'JSONWebToken'
			with: [ spec loads: 'JSONWebToken-Core' ]
]

{ #category : #baselines }
BaselineOfStargate >> setUpDeploymentPackages: spec [

	spec
		package: 'Stargate-Model'
			with: [ spec
				requires: #('Buoy-Deployment' 'Hyperspace-Deployment' 'Teapot-Deployment' 'JSONWebToken-Deployment')
			];
		group: 'Core' with: 'Stargate-Model';
		group: 'Deployment' with: 'Stargate-Model'.

	spec
		package: 'Stargate-HealthCheck' with: [ spec requires: 'Stargate-Model' ];
		group: 'HealthCheck' with: 'Stargate-HealthCheck';
		group: 'Deployment' with: 'Stargate-HealthCheck'.

	spec
		package: 'Stargate-Metrics' with: [ spec requires: 'Stargate-Model' ];
		group: 'Metrics' with: 'Stargate-Metrics';
		group: 'Deployment' with: 'Stargate-Metrics'
]

{ #category : #baselines }
BaselineOfStargate >> setUpPackages: spec [

	self setUpDeploymentPackages: spec.
	spec
		package: 'Stargate-Examples' with: [ spec requires: 'Stargate-Model' ];
		group: 'Examples' with: 'Stargate-Examples'.
	spec
		package: 'Stargate-SUnit-Model' with: [ spec requires: #('Stargate-Model' 'Buoy-SUnit') ];
		group: 'Dependent-SUnit-Extensions' with: 'Stargate-SUnit-Model'.
	self setUpTestPackages: spec
]

{ #category : #baselines }
BaselineOfStargate >> setUpTestPackages: spec [

	spec
		package: 'Stargate-Model-Tests'
			with: [ spec requires: #('Stargate-Model' 'Stargate-Examples' 'Stargate-HealthCheck') ];
		group: 'Tests' with: 'Stargate-Model-Tests'.
	spec
		package: 'Stargate-HealthCheck-Tests'
			with: [ spec requires: #('Stargate-HealthCheck' 'Stargate-Model-Tests') ];
		group: 'Tests' with: 'Stargate-HealthCheck-Tests'.
	spec
		package: 'Stargate-Metrics-Tests'
			with: [ spec requires: #('Stargate-Metrics' 'Stargate-Model-Tests') ];
		group: 'Tests' with: 'Stargate-Metrics-Tests'.
	spec
		package: 'Stargate-Examples-Tests'
			with: [ spec requires: #('Dependent-SUnit-Extensions' 'Stargate-Examples') ];
		group: 'Tests' with: 'Stargate-Examples-Tests'
]
