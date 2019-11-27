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

	^ Array with: ( FlagArgument named: 'debug-mode' )
]

{ #category : #private }
ApplicationConfigurationPluginAPITest >> configurationProvider [

	^ [ Dictionary new
		at: 'debug-mode' put: true;
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
						assert: config name equals: 'debug-mode';
						assert: ( config at: #'current-value' )
					]
			]
]
