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
		'enabledOperationalPlugins'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
HTTPBasedRESTfulAPI class >> configuredBy: configuration installing: aRESTfulControllerCollection [

	AssertionChecker enforce: [ aRESTfulControllerCollection notEmpty ] because: 'An API needs at least to expose one resource'.
	^ self new initializeConfiguredBy: configuration installing: aRESTfulControllerCollection
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
	controllers add: pluginToEnable controller
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aRESTfulControllerCollection [

	teapotServer := Teapot
		configure: configuration , { #notFoundHandlerClass -> Tea405AwareNotFoundHandler }.
	self
		initializeControllersWithAll: aRESTfulControllerCollection;
		initializeErrorHandlers;
		initializeEnabledOperationalPluginsBy: configuration
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeControllersWithAll: aRESTfulControllerCollection [

	controllers := OrderedCollection with: ( OperationalPluginsRESTfulController on: self ).
	controllers addAll: aRESTfulControllerCollection
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeEnabledOperationalPluginsBy: configuration [

	enabledOperationalPlugins := OrderedCollection new.
	self enable: HealthCheckPlugin endpoint configuredBy: configuration 
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

{ #category : #actions }
HTTPBasedRESTfulAPI >> start [

	teapotServer start
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> stop [

	teapotServer stop
]
