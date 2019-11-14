"
I represent an HTTP based RESTful API, serving one or more services.
"
Class {
	#name : #HTTPBasedRESTfulAPI,
	#superclass : #Object,
	#instVars : [
		'teapotServer',
		'controllers',
		'errorHandlers',
		'enabledOperationalPlugins',
		'operationsConfiguration'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
HTTPBasedRESTfulAPI class >> configuredBy: configuration installing: aRESTfulControllerCollection [

	AssertionChecker enforce: [ aRESTfulControllerCollection notEmpty ] because: 'An API needs at least to expose one resource'.
	^ self new initializeConfiguredBy: configuration installing: aRESTfulControllerCollection
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> addController: aRESTfulController [

	controllers add: aRESTfulController
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> beCORSAwareAllowing: origins [

	teapotServer
		after: '/*' -> (CrossOriginResourceSharingAfterFilter allowing: origins);
		when: [ :request | request headers includesKey: 'Origin' ]
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureErrorHandlers [

	errorHandlers do: [ :errorHandler | teapotServer exception: errorHandler ]
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutes [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	controllers do: [ :controller | configurator addRoutesOf: controller ]
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> enable: anOperationalPluginEndpoint configuredBy: configuration [

	| pluginToEnable |

	pluginToEnable := ( OperationalPlugin pluginAt: anOperationalPluginEndpoint )
		configuredBy: configuration.
	enabledOperationalPlugins add: pluginToEnable.
	pluginToEnable includeControllersIn: self
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aRESTfulControllerCollection [

	teapotServer := Teapot
		configure: configuration , {( #notFoundHandlerClass -> Tea405AwareNotFoundHandler )}.
	operationsConfiguration := configuration asDictionary at: #operations.
	self
		initializeControllersWithAll: aRESTfulControllerCollection;
		initializeErrorHandlers;
		initializeEnabledOperationalPlugins
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeControllersWithAll: aRESTfulControllerCollection [

	controllers := OrderedCollection with: ( OperationalPluginsRESTfulController on: self ).
	controllers addAll: aRESTfulControllerCollection
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeEnabledOperationalPlugins [

	enabledOperationalPlugins := OrderedCollection new.
	OperationalPlugin availablePlugins
		select: [ :plugin | 
			operationsConfiguration
				at: plugin endpoint
				ifPresent: [ :pluginConfiguration | pluginConfiguration at: #enabled ifAbsent: [ plugin enabledByDefault ] ]
				ifAbsent: [ plugin enabledByDefault ]
			]
		thenDo: [ :plugin | self enable: plugin endpoint configuredBy: operationsConfiguration ]
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeErrorHandlers [

	errorHandlers := OrderedCollection new.
	self
		on: HTTPClientError
		addErrorHandler: [ :clientError :request | 
			| json |

			json := NeoJSONWriter toStringPretty: clientError.
			( ZnResponse statusCode: clientError code )
				headers:
					( ZnHeaders defaultResponseHeaders
						at: 'Access-Control-Allow-Origin' put: '*';
						yourself );
				entity: ( ZnEntity json: json );
				yourself
			]
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> install [

	self
		configureRoutes;
		configureErrorHandlers
]

{ #category : #testing }
HTTPBasedRESTfulAPI >> isEnabled: aPluginType [

	^ enabledOperationalPlugins anySatisfy: [ :plugin | plugin isA: aPluginType ]
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> on: exception addErrorHandler: aDyadicBlock [

	errorHandlers add: exception -> aDyadicBlock
]

{ #category : #accessing }
HTTPBasedRESTfulAPI >> operationsConfiguration [

	^ operationsConfiguration
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> start [

	enabledOperationalPlugins do: [ :plugin | plugin startOn: teapotServer ].
	teapotServer start
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> stop [

	teapotServer stop.
	enabledOperationalPlugins do: #stop
]
