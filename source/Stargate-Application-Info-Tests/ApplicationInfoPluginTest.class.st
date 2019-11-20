"
An ApplicationInfoPluginTest is a test class for testing the behavior of ApplicationInfoPlugin
"
Class {
	#name : #ApplicationInfoPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Application-Info-Tests'
}

{ #category : #private }
ApplicationInfoPluginTest >> asPluginConfiguration: configuration [

	^ Dictionary new
		at: ApplicationInfoPlugin endpoint put: configuration;
		yourself
]

{ #category : #private }
ApplicationInfoPluginTest >> asPluginConfigurationGathering: infoProviderNames [

	^ self
		asPluginConfiguration:
			( Dictionary new
				at: #enabled put: true;
				at: #'info-providers' put: infoProviderNames;
				yourself )
]

{ #category : #private }
ApplicationInfoPluginTest >> assertOperatingSystemInformationOn: info [

	info
		at: 'os'
		ifPresent: [ :osData | 
			osData
				at: 'general'
				ifPresent: [ :generalData | 
					self
						assert: ( generalData includesKey: 'platform' );
						assert: ( generalData includesKey: 'version' );
						assert: ( generalData includesKey: 'subtype' )
					]
				ifAbsent: [ self fail ]
			]
		ifAbsent: [ self fail ]
]

{ #category : #private }
ApplicationInfoPluginTest >> assertPharoInformationOn: info [

	info
		at: 'pharo'
		ifPresent: [ :pharoData | 
			pharoData
				at: 'image'
				ifPresent: [ :imageData | 
					self
						assert: ( imageData includesKey: 'version' );
						assert: ( imageData includesKey: 'build-info' );
						assert: ( imageData includesKey: 'build-commit' );
						assert: ( imageData includesKey: 'command-line-parameters' );
						assert: ( imageData includesKey: 'location' )
					]
				ifAbsent: [ self fail ].
			pharoData
				at: 'vm'
				ifPresent: [ :vmData | 
					self
						assert: ( vmData includesKey: 'version' );
						assert: ( vmData includesKey: 'architecture' );
						assert: ( vmData includesKey: 'image-version-format' );
						assert: ( vmData includesKey: 'location' );
						assert: ( vmData includesKey: 'options' );
						assert: ( vmData includesKey: 'modules' );
						assert: ( vmData includesKey: 'parameters' )
					]
				ifAbsent: [ self fail ]
			]
		ifAbsent: [ self fail ]
]

{ #category : #test }
ApplicationInfoPluginTest >> testConfiguredUsingDefaults [

	| plugin info |

	plugin := ApplicationInfoPlugin
		configuredBy: ( self asPluginConfiguration: {( #enabled -> true )} asDictionary ).

	info := plugin gatherInformation.

	self
		assert: info size equals: 2;
		assertPharoInformationOn: info;
		assertOperatingSystemInformationOn: info
]

{ #category : #test }
ApplicationInfoPluginTest >> testConfiguredWithAllProviders [

	| plugin |

	plugin := ApplicationInfoPlugin
		configuredBy: ( self asPluginConfigurationGathering: ApplicationInformationProvider allProviderNames ).

	self assert: plugin gatherInformation size equals: 3
]

{ #category : #test }
ApplicationInfoPluginTest >> testConfiguredWithoutProviders [

	| plugin |

	plugin := ApplicationInfoPlugin configuredBy: ( self asPluginConfigurationGathering: #() ).

	self assert: plugin gatherInformation isEmpty
]

{ #category : #test }
ApplicationInfoPluginTest >> testDefaultProviders [

	self assert: ApplicationInfoPlugin defaultProviderNames equals: #('os' 'pharo')
]

{ #category : #test }
ApplicationInfoPluginTest >> testEnabledByDefault [

	self deny: ApplicationInfoPlugin enabledByDefault
]

{ #category : #test }
ApplicationInfoPluginTest >> testEndpoint [

	self assert: ApplicationInfoPlugin endpoint equals: 'application-info'
]

{ #category : #test }
ApplicationInfoPluginTest >> testPluginName [

	self assert: ApplicationInfoPlugin pluginName equals: 'Application Information'
]

{ #category : #test }
ApplicationInfoPluginTest >> testPrintOn [

	self assert: ApplicationInfoPlugin new printString equals: 'Application Information'
]
