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
			spec package: 'Stargate-REST-API' with: [ spec requires: #('Buoy' 'Teapot') ].
			spec package: 'Stargate-Examples' with: [ spec requires: 'Stargate-REST-API' ].
			spec package: 'Stargate-REST-API-Tests' with: [ spec requires: #('Stargate-REST-API' 'Stargate-Examples') ].
			spec
				group: 'Deployment' with: #('Stargate-REST-API');
				group: 'Development' with: #('Deployment' 'Stargate-REST-API-Tests');
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
