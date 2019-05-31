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
				group: 'Tools' with: #('Buoy-Tools' 'Teapot-Tools');
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
		project: 'Buoy-SUnit' copyFrom: 'Buoy' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Buoy-Tools' copyFrom: 'Buoy' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Teapot' with: [ spec repository: 'github://zeroflag/Teapot:v2.6.0/source' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ];
		project: 'Teapot-Tools' copyFrom: 'Teapot' with: [ spec loads: 'Tools' ]
]

{ #category : #baselines }
BaselineOfStargate >> setUpPackages: spec [

	spec
		package: 'Stargate-Model' with: [ spec requires: #('Buoy-Deployment' 'Teapot-Deployment') ];
		group: 'Deployment' with: 'Stargate-Model'.
	spec
		package: 'Stargate-Examples' with: [ spec requires: 'Stargate-Model' ];
		group: 'Examples' with: 'Stargate-Examples'.
	spec
		package: 'Stargate-SUnit-Model' with: [ spec requires: #('Stargate-Model' 'Buoy-SUnit') ];
		group: 'Dependent-SUnit-Extensions' with: 'Stargate-SUnit-Model'.
	spec
		package: 'Stargate-Model-Tests' with: [ spec requires: #('Stargate-Model' 'Stargate-Examples') ];
		group: 'Tests' with: 'Stargate-Model-Tests'.
	spec
		package: 'Stargate-Examples-Tests'
			with: [ spec requires: #('Dependent-SUnit-Extensions' 'Stargate-Examples') ];
		group: 'Tests' with: 'Stargate-Examples-Tests'
]
