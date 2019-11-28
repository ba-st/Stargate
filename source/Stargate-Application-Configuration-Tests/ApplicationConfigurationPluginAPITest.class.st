"
I'm the test case for the Application Configuration API
"
Class {
	#name : #ApplicationConfigurationPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #private }
ApplicationConfigurationPluginAPITest >> configurationDefinitions [

	^ Array with: ( MandatoryArgument named: 'public-url' )
]

{ #category : #private }
ApplicationConfigurationPluginAPITest >> configurationProvider [

	^ [ Dictionary new
		at: 'public-url' put: 'http://api.example.com' asUrl;
		yourself
	]
]

{ #category : #running }
ApplicationConfigurationPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationConfigurationPlugin endpoint
		put: {
				#enabled -> true .
				#definitions -> self configurationDefinitions .
				#provider -> self configurationProvider 
				} asDictionary;
		yourself
]

{ #category : #private }
ApplicationConfigurationPluginAPITest >> requiredPermissions [

	^ #('read:application-configuration')
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
						assert: config name equals: 'public-url';
						assert: ( config at: #'current-value' ) equals: 'http://api.example.com/'
					]
			]
]
