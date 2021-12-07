"
I'm the test case for the Application Configuration API
"
Class {
	#name : #ApplicationConfigurationPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #private }
ApplicationConfigurationPluginAPITest >> configurationParameters [

	^ Array with: ( MandatoryConfigurationParameter named: 'Public URL' describedBy: 'Public URL' )
]

{ #category : #private }
ApplicationConfigurationPluginAPITest >> configurationProvider [

	^ [ 
	  ApplicationConfiguration forAll: self configurationParameters
		  providedBy: ( ConfigurationFromCommandLineProvider over:
				    ( CommandLineArguments withArguments: #( '--public-url=https://api.example.com' ) ) )
	  ]
]

{ #category : #running }
ApplicationConfigurationPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationConfigurationPlugin endpoint
		put: {
				#enabled -> true .
				#parameters -> self configurationParameters .
				#provider -> self configurationProvider 
				} asDictionary;
		yourself
]

{ #category : #private }
ApplicationConfigurationPluginAPITest >> requiredPermissions [

	^ #('read:application-configuration')
]

{ #category : #tests }
ApplicationConfigurationPluginAPITest >> testDisablePlugin [

	self assertIsEnabled: ApplicationConfigurationPlugin.

	api disable: ApplicationConfigurationPlugin.
	self assertIsDisabled: ApplicationConfigurationPlugin.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationConfigurationPlugin endpoint asUrl;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #tests }
ApplicationConfigurationPluginAPITest >> testEnablePreviouslyDisabledPlugin [

	self assertIsEnabled: ApplicationConfigurationPlugin.

	api disable: ApplicationConfigurationPlugin.
	self assertIsDisabled: ApplicationConfigurationPlugin.

	api enable: ApplicationConfigurationPlugin.
	self assertIsEnabled: ApplicationConfigurationPlugin.

	self testGetConfigurationWithPermissions
]

{ #category : #tests }
ApplicationConfigurationPluginAPITest >> testGetConfigurationWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationConfigurationPlugin endpoint asUrl;
		setAccept: ZnMimeType applicationJson;
		get;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: 'application/vnd.stargate.operational-application-configuration+json;version=1.0.0' asMediaType;
		withJsonFromContentsIn: response
			do: [ :configurations | 
			self
				withTheOnlyOneIn: configurations
				do: [ :config | 
					self
						assert: config commandLineArgumentName equals: 'public-url';
						assert: ( config at: #'current-value' ) equals: 'https://api.example.com'
					]
			]
]
