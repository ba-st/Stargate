"
An ApplicationConfigurationRESTfulControllerTest is a test class for testing the behavior of ApplicationConfigurationRESTfulController
"
Class {
	#name : #ApplicationConfigurationRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> configurationParameters [

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
		  with:
			  ( MandatoryConfigurationParameter named: 'Secret' describedBy: 'Secret' inside: #( 'Vault' ) )
				  asSensitive
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> configurationProvider [

	^ [ 
	  ApplicationConfiguration forAll: self configurationParameters
		  providedBy: ( ConfigurationFromCommandLineProvider over: ( CommandLineArguments withArguments:
					      #( '--port=6000' '--base-url=https://api.example.com'
					         '--debug-mode=true' '--vault.secret==XXX' ) ) )
	  ]
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationConfigurationPlugin endpoint
		put: {
				#enabled -> true .
				#parameters -> self configurationParameters .
				#provider -> self configurationProvider 
				} asDictionary;
		yourself
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> setUpResourceController [

	resourceController := ApplicationConfigurationRESTfulController
		over: ( ApplicationConfigurationPlugin configuredBy: self operationsConfiguration )
		configuredBy: self operationsConfiguration
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> testGetConfigurationInJson [

	| response |

	response := resourceController getApplicationConfigurationBasedOn:
		            ( self requestToGET: self resourceUrl accepting: ZnMimeType applicationJson )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
		equals: resourceController operationalApplicationConfigurationVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response do: [ :configs | 
			self
				assert: configs size equals: 4;
				withConfigurationNamed: 'Port' in: configs do: [ :config | 
					self
						assert: config type equals: 'optional';
						assert: config summary equals: 'Listening Port. Defaults to 4000';
						assert: config attributeName equals: 'port';
						assert: config commandLineArgumentName equals: 'port';
						assert: config environmentVariableName equals: 'PORT';
						assert: config sections isEmpty;
						assert: ( config at: #'current-value' ) equals: 6000;
						assert: config default equals: 4000
					];
				withConfigurationNamed: 'Base URL' in: configs do: [ :config | 
				self
					assert: config type equals: 'mandatory';
					assert: config summary equals: 'Base URL';
					assert: config attributeName equals: 'baseURL';
					assert: config commandLineArgumentName equals: 'base-url';
					assert: config environmentVariableName equals: 'BASE_URL';
					assert: config sections isEmpty;
					assert: ( config at: #'current-value' ) equals: 'https://api.example.com'
				];
				withConfigurationNamed: 'Debug Mode' in: configs do: [ :config | 
				self
					assert: config type equals: 'optional';
					assert: config summary equals: 'Debugging Mode Flag. Defaults to false';
					assert: config attributeName equals: 'debugMode';
					assert: config commandLineArgumentName equals: 'debug-mode';
					assert: config environmentVariableName equals: 'DEBUG_MODE';
					assert: config sections isEmpty;
					assert: ( config at: #'current-value' );
					deny: config default
				];
				withConfigurationNamed: 'Secret' in: configs do: [ :config | 
				self
					assert: config type equals: 'sensitive';
					assert: config summary equals: 'Secret';
					assert: config attributeName equals: 'secret';
					assert: config commandLineArgumentName equals: 'vault.secret';
					assert: config environmentVariableName equals: 'VAULT__SECRET';
					assert: config sections equals: #( 'Vault' );
					assert: ( config at: #'current-value' ) equals: '********'
				]
			]
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> testGetConfigurationInPlainText [

	| response |

	response := resourceController
		getApplicationConfigurationBasedOn: ( self requestToGET: self resourceUrl accepting: ZnMimeType textPlain )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ( ZnMimeType textPlain version: '1.0.0' );
		assert: response contents
			equals:
			( 'port = 6000<1s><2s>base-url = https://api.example.com<1s><2s>debug-mode = true<1s><2s>vault.secret = ********'
				expandMacrosWith: String cr
				with: String lf )
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> withConfigurationNamed: aName in: configurations do: aBlock [

	configurations detect: [ :config | config name = aName ] ifFound: aBlock ifNone: [ self fail ]
]
