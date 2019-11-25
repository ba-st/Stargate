"
An ApplicationConfigurationRESTfulControllerTest is a test class for testing the behavior of ApplicationConfigurationRESTfulController
"
Class {
	#name : #ApplicationConfigurationRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> configurationDefinitions [

	^ Array
		with: ( OptionalArgument named: 'port' defaultingTo: 4000 )
		with: ( MandatoryArgument named: 'base-url' )
		with: ( FlagArgument named: 'debug-mode' )
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> configurationProvider [

	^ [ Dictionary new
		at: 'port' put: 6000;
		at: 'base-url' put: 'https://api.example.com';
		at: 'debug-mode' put: true;
		yourself
	]
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationConfigurationPlugin endpoint
		put: {
				#enabled -> true .
				#definitions -> self configurationDefinitions .
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

	response := resourceController
		getApplicationConfigurationBasedOn: ( self requestToGET: self resourceUrl accepting: ZnMimeType applicationJson )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController operationalApplicationConfigurationVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :configs | 
			self
				assert: configs size equals: 3;
				withConfigurationNamed: 'port'
					in: configs
					do: [ :config | 
					self
						assert: ( config at: #'current-value' ) equals: 6000;
						assert: config default equals: 4000
					];
				withConfigurationNamed: 'base-url'
					in: configs
					do: [ :config | self assert: ( config at: #'current-value' ) equals: 'https://api.example.com' ];
				withConfigurationNamed: 'debug-mode'
					in: configs
					do: [ :config | self assert: ( config at: #'current-value' ) ]
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
			( 'port = 6000<1s><2s>base-url = https://api.example.com<1s><2s>debug-mode = true'
				expandMacrosWith: String cr
				with: String lf )
]

{ #category : #'private - support' }
ApplicationConfigurationRESTfulControllerTest >> withConfigurationNamed: aName in: configurations do: aBlock [

	configurations detect: [ :config | config name = aName ] ifFound: aBlock ifNone: [ self fail ]
]
