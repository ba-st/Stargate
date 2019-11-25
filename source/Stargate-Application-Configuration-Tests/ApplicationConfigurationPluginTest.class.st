"
An ApplicationConfigurationPluginTest is a test class for testing the behavior of ApplicationConfigurationPlugin
"
Class {
	#name : #ApplicationConfigurationPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #accessing }
ApplicationConfigurationPluginTest >> configuration [

	^ Dictionary new
		at: ApplicationConfigurationPlugin endpoint
			put: {
				#enabled -> true .
				#definitions -> self configurationDefinitions .
				#provider -> self configurationProvider 
				} asDictionary;
		yourself
]

{ #category : #accessing }
ApplicationConfigurationPluginTest >> configurationDefinitions [

	^ Array
		with: ( OptionalArgument named: 'port' defaultingTo: 4000 )
		with: ( MandatoryArgument named: 'base-url' )
		with: ( FlagArgument named: 'debug-mode' )
]

{ #category : #accessing }
ApplicationConfigurationPluginTest >> configurationProvider [

	^ [ Dictionary new
		at: 'port' put: 6000;
		at: 'base-url' put: 'https://api.example.com';
		at: 'debug-mode' put: true;
		yourself
	]
]

{ #category : #tests }
ApplicationConfigurationPluginTest >> testConfigurationAccessing [

	| plugin definition |

	plugin := ApplicationConfigurationPlugin configuredBy: self configuration.

	self assert: plugin configurationDefinitions size equals: 3.

	definition := plugin configurationDefinitions first.

	self
		assert: definition name equals: 'port';
		assert: definition default equals: 4000;
		assert: ( plugin currentValueFor: definition ) equals: 6000.

	definition := plugin configurationDefinitions second.

	self
		assert: definition name equals: 'base-url';
		assert: ( plugin currentValueFor: definition ) equals: 'https://api.example.com'.

	definition := plugin configurationDefinitions last.

	self
		assert: definition name equals: 'debug-mode';
		assert: ( plugin currentValueFor: definition )
]

{ #category : #tests }
ApplicationConfigurationPluginTest >> testEnabledByDefault [

	self deny: ApplicationConfigurationPlugin enabledByDefault
]

{ #category : #tests }
ApplicationConfigurationPluginTest >> testEndpoint [

	self assert: ApplicationConfigurationPlugin endpoint equals: 'application-configuration'
]

{ #category : #tests }
ApplicationConfigurationPluginTest >> testPluginName [

	self assert: ApplicationConfigurationPlugin pluginName equals: 'Application Configuration'
]
