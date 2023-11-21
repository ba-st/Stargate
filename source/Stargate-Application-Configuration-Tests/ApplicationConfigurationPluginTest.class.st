"
An ApplicationConfigurationPluginTest is a test class for testing the behavior of ApplicationConfigurationPlugin
"
Class {
	#name : 'ApplicationConfigurationPluginTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Application-Configuration-Tests',
	#package : 'Stargate-Application-Configuration-Tests'
}

{ #category : 'accessing' }
ApplicationConfigurationPluginTest >> configuration [

	^ Dictionary new
		at: ApplicationConfigurationPlugin endpoint
			put: {
				#enabled -> true .
				#parameters -> self configurationParameters .
				#provider -> self configurationProvider 
				} asDictionary;
		yourself
]

{ #category : 'accessing' }
ApplicationConfigurationPluginTest >> configurationParameters [

	^ Array
		  with: ( OptionalConfigurationParameter named: 'Port'
				    describedBy: 'Listening Port'
				    defaultingTo: 4000
				    convertingWith: #asNumber )
		  with: ( MandatoryConfigurationParameter named: 'Base URL' describedBy: 'Base URL' )
		  with: ( OptionalConfigurationParameter named: 'Debug Mode'
				    describedBy: 'Debugging Mode Flag'
				    defaultingTo: false
				    convertingWith: [ :value | value = 'true' ] )
]

{ #category : 'accessing' }
ApplicationConfigurationPluginTest >> configurationProvider [

	^ [ 
	  ApplicationConfiguration forAll: self configurationParameters
		  providedBy: ( ConfigurationFromCommandLineProvider over: ( CommandLineArguments withArguments:
					      #( '--port=6000' '--base-url=https://api.example.com'
					         '--debug-mode=true' ) ) )
	  ]
]

{ #category : 'tests' }
ApplicationConfigurationPluginTest >> testConfigurationAccessing [

	| plugin parameter |

	plugin := ApplicationConfigurationPlugin configuredBy: self configuration.

	self assert: plugin configurationParameters size equals: 3.

	parameter := plugin configurationParameters first.

	self
		assert: parameter name equals: 'Port';
		assert: ( plugin currentValueFor: parameter ) equals: 6000.

	parameter := plugin configurationParameters second.

	self
		assert: parameter name equals: 'Base URL';
		assert: ( plugin currentValueFor: parameter ) equals: 'https://api.example.com'.

	parameter := plugin configurationParameters last.

	self
		assert: parameter name equals: 'Debug Mode';
		assert: ( plugin currentValueFor: parameter )
]

{ #category : 'tests' }
ApplicationConfigurationPluginTest >> testEnabledByDefault [

	self deny: ApplicationConfigurationPlugin enabledByDefault
]

{ #category : 'tests' }
ApplicationConfigurationPluginTest >> testEndpoint [

	self assert: ApplicationConfigurationPlugin endpoint equals: 'application-configuration'
]

{ #category : 'tests' }
ApplicationConfigurationPluginTest >> testPluginName [

	self assert: ApplicationConfigurationPlugin pluginName equals: 'Application Configuration'
]
