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
				group: 'Tools' with: #('Hyperspace-Tools');
				group: 'Development' with: #('Tests' 'Tools')
			]
]

{ #category : #accessing }
BaselineOfStargate >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfStargate >> setUpCorePackages: spec [

	spec
		package: 'Stargate-Model' with: [
			spec requires:
					#( 'Buoy-Deployment' 'Hyperspace-Deployment'
					   'Teapot-Deployment' 'JSONWebToken-Deployment' ) ];
		group: 'Core' with: 'Stargate-Model';
		group: 'Deployment' with: 'Stargate-Model'.

	#( 'Stargate-Zinc-Extensions' 'Stargate-Teapot-Extensions'
	   'Stargate-NeoJSON-Extensions' 'Stargate-JSONWebToken-Extensions'
	   'Stargate-Hyperspace-Extensions' ) do: [ :extensionPackageName |
		spec
			package: extensionPackageName
			with: [ spec requires: 'Stargate-Model' ];
			group: 'Core' with: extensionPackageName;
			group: 'Deployment' with: extensionPackageName ]
]

{ #category : #baselines }
BaselineOfStargate >> setUpDependencies: spec [

	spec
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v6' ];
		project: 'Buoy-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ];
		project: 'Buoy-SUnit' copyFrom: 'Buoy' with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Hyperspace' with: [ spec repository: 'github://ba-st/Hyperspace:v4' ];
		project: 'Hyperspace-Deployment' copyFrom: 'Hyperspace' with: [ spec loads: 'Deployment' ];
    project: 'Hyperspace-Tools' copyFrom: 'Hyperspace' with: [ spec loads: 'Tools' ];
		project: 'Hyperspace-SUnit'
		copyFrom: 'Hyperspace'
		with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Teapot' with: [ spec repository: 'github://zeroflag/Teapot:v2.7.0/source' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'JSONWebToken' with: [ spec repository: 'github://noha/JSONWebToken:0.3/source' ];
		project: 'JSONWebToken-Deployment'
		copyFrom: 'JSONWebToken'
		with: [ spec loads: 'JSONWebToken-Core' ].

	spec
		baseline: 'JRPC' with: [ spec repository: 'github://juliendelplanque/JRPC:v3.x.x/src' ];
		project: 'JRPC-Deployment' copyFrom: 'JRPC' with: [ spec loads: 'Server-Deployment' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v4' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'ZTimestamp' with: [ spec repository: 'github://svenvc/ztimestamp' ];
		project: 'ZTimestamp-Core' copyFrom: 'ZTimestamp' with: [ spec loads: 'core' ]
]

{ #category : #baselines }
BaselineOfStargate >> setUpDeploymentPackages: spec [

	self setUpCorePackages: spec.
	spec
		package: 'Stargate-HealthCheck' with: [ spec requires: 'Core' ];
		group: 'HealthCheck' with: 'Stargate-HealthCheck';
		group: 'Deployment' with: 'HealthCheck'.
	spec
		package: 'Stargate-Metrics' with: [ spec requires: 'Core' ];
		group: 'Metrics' with: 'Stargate-Metrics';
		group: 'Deployment' with: 'Metrics'.
	spec
		package: 'Stargate-Metrics-HTTP'
		with: [ spec requires: 'Stargate-Metrics' ];
		group: 'Metrics-HTTP' with: 'Stargate-Metrics-HTTP';
		group: 'Deployment' with: 'Metrics-HTTP'.
	spec
		package: 'Stargate-JSON-RPC'
		with: [ spec requires: #( 'Core' 'JRPC-Deployment' ) ];
		group: 'JSON-RPC' with: 'Stargate-JSON-RPC';
		group: 'Deployment' with: 'JSON-RPC'.
	spec
		package: 'Stargate-Application-Control'
		with: [ spec requires: #( 'Core' 'JSON-RPC' ) ];
		group: 'Application-Control' with: 'Stargate-Application-Control';
		group: 'Deployment' with: 'Application-Control'.
	spec
		package: 'Stargate-Application-Info'
		with: [ spec requires: 'Core' ];
		group: 'Application-Info' with: 'Stargate-Application-Info';
		group: 'Deployment' with: 'Application-Info'.
	spec
		package: 'Stargate-Application-Configuration'
		with: [ spec requires: #( 'Core' 'Launchpad-Deployment' ) ];
		group: 'Application-Configuration'
		with: 'Stargate-Application-Configuration';
		group: 'Deployment' with: 'Application-Configuration'.
	spec
		package: 'Stargate-Loggers'
		with: [ spec requires: #( 'Core' 'Launchpad-Deployment' ) ];
		group: 'Loggers' with: 'Stargate-Loggers';
		group: 'Deployment' with: 'Loggers'.
	spec
		package: 'Stargate-API-Skeleton' with: [
			spec requires:
					#( 'Metrics-HTTP' 'Application-Control' 'Application-Info'
					   'Application-Configuration' 'Launchpad-Deployment'
					   'ZTimestamp-Core' ) ];
		group: 'Deployment' with: 'Stargate-API-Skeleton'
]

{ #category : #baselines }
BaselineOfStargate >> setUpPackages: spec [

	self setUpDeploymentPackages: spec.
	spec
		package: 'Stargate-Examples' with: [ spec requires: 'Stargate-API-Skeleton' ];
		group: 'Examples' with: 'Stargate-Examples'.
	spec
		package: 'Stargate-SUnit-Model' with: [ spec requires: #('Stargate-Model' 'Buoy-SUnit' 'Hyperspace-SUnit') ];
		group: 'Dependent-SUnit-Extensions' with: 'Stargate-SUnit-Model'.
	self setUpTestPackages: spec
]

{ #category : #baselines }
BaselineOfStargate >> setUpTestPackages: spec [

	spec
		package: 'Stargate-Model-Tests' with: [ 
			spec requires:
					#( 'Stargate-Model' 'Stargate-Examples' 'Stargate-HealthCheck' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Stargate-Model-Tests'.
	spec
		package: 'Stargate-HealthCheck-Tests'
		with: [ spec requires: #( 'Stargate-HealthCheck' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-HealthCheck-Tests'.
	spec
		package: 'Stargate-Metrics-Tests'
		with: [ spec requires: #( 'Stargate-Metrics' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Metrics-Tests'.
	spec
		package: 'Stargate-Metrics-HTTP-Tests'
		with: [ spec requires: #( 'Stargate-Metrics-HTTP' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Metrics-HTTP-Tests'.
	spec
		package: 'Stargate-Application-Control-Tests'
		with: [ spec requires: #( 'Stargate-Application-Control' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Application-Control-Tests'.
	spec
		package: 'Stargate-Application-Info-Tests'
		with: [ spec requires: #( 'Application-Info' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Application-Info-Tests'.
	spec
		package: 'Stargate-Application-Configuration-Tests'
		with: [ spec requires: #( 'Application-Configuration' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Application-Configuration-Tests'.
	spec
		package: 'Stargate-Loggers-Tests' with: [ spec requires: #( 'Loggers' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-Loggers-Tests'.
	spec
		package: 'Stargate-JSON-RPC-Tests'
		with: [ spec requires: #( 'JSON-RPC' 'Stargate-Model-Tests' ) ];
		group: 'Tests' with: 'Stargate-JSON-RPC-Tests'.
	spec
		package: 'Stargate-API-Skeleton-Tests'
		with: [ spec requires: #( 'Dependent-SUnit-Extensions' 'Stargate-Examples' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Stargate-API-Skeleton-Tests'.
	spec
		package: 'Stargate-Examples-Tests'
		with: [ spec requires: #( 'Dependent-SUnit-Extensions' 'Stargate-Examples' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Stargate-Examples-Tests'
]
