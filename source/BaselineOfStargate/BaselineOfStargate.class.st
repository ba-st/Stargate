Class {
	#name : #BaselineOfStargate,
	#superclass : #BaselineOf,
	#category : #BaselineOfStargate
}

{ #category : #baselines }
BaselineOfStargate >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
			spec package: 'Stargate-Model' with: [ spec requires: #('Buoy' 'Teapot') ].
			spec package: 'Stargate-Examples' with: [ spec requires: 'Stargate-Model' ].
			spec package: 'Stargate-Model-Tests' with: [ spec requires: #('Stargate-Model') ].
			spec package: 'Stargate-Examples-Tests' with: [ spec requires: #('Stargate-Model-Tests' 'Stargate-Examples') ].
			spec
				group: 'Deployment' with: #('Stargate-Model');
				group: 'Examples' with: #('Deployment' 'Stargate-Examples');
				group: 'Tests' with: #('Examples' 'Stargate-Examples-Tests' 'Stargate-Model-Tests');
				group: 'Development' with: #('Tests');
				group: 'default' with: #('Deployment') ]
]

{ #category : #baselines }
BaselineOfStargate >> setUpDependencies: spec [

	spec
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v4/source' ];
		import: 'Buoy'.
		
	spec
		configuration: 'Teapot'
		with: [ spec
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/zeroflag/Teapot/main/';
				loads: #('Teapot-Core' 'Teapot-Tools') ]
]
