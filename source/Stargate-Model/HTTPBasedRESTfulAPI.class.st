"
I represent an HTTP based RESTful API, serving one or more services.
"
Class {
	#name : 'HTTPBasedRESTfulAPI',
	#superclass : 'Object',
	#instVars : [
		'teapotServer',
		'controllers',
		'errorHandlers',
		'enabledOperationalPlugins',
		'operationsConfiguration',
		'disabledOperationalPlugins',
		'optionalCORSHandler'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
HTTPBasedRESTfulAPI class >> configuredBy: configuration installing: aRESTfulControllerCollection [

	AssertionChecker enforce: [ aRESTfulControllerCollection notEmpty ] because: 'An API needs at least to expose one resource'.
	^ self new initializeConfiguredBy: configuration installing: aRESTfulControllerCollection
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> addController: aRESTfulController [

	controllers add: aRESTfulController
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> allowCrossOriginSharingApplying: aConfigurationBlock [

	| builder |

	builder := aConfigurationBlock value:
		           ( CrossOriginResourceSharingFilterBuilder using: controllers ).
	builder buildPreflightFilter applyOn: teapotServer.
	builder buildActualRequestFilter applyOn: teapotServer.
	optionalCORSHandler := Optional containing: builder actualRequestHandler
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> applyCrossSharingResourceConfigurationTo: response accordingTo: request [

	optionalCORSHandler withContentDo: [ :handler |
		( request headers includesKey: 'Origin' ) then: [
			handler teaEvalActionOnRequest: request response: response ]
		]
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> authenticatedBy: anAuthorizationFilter [

	teapotServer
		before: '/*' -> anAuthorizationFilter;
		when: [ :request | ( CrossOriginResourceSharingFilter isForPreflight: request ) not ]
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> configureErrorHandlers [

	errorHandlers do: [ :errorHandler | teapotServer exception: errorHandler ]
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutes [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	controllers do: [ :controller | configurator addRoutesOf: controller ]
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutesDeclaredByPlugin: anOperationalPluginType [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	^ self withControllersDefinedByPlugin: anOperationalPluginType
		  do: [ :controller | configurator addRoutesOf: controller ]
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> disable: anOperationalPluginType [

	enabledOperationalPlugins
		detect: [ :plugin | plugin endpoint = anOperationalPluginType endpoint ]
		ifFound: [ :pluginToDisable | 
			self
				markAsDisabled: pluginToDisable;
				withConfigurationOf: pluginToDisable
				do: [ :configuration | configuration at: #enabled put: false ]
				ifAbsent: [  ];
				removeRoutesDeclaredByPlugin: anOperationalPluginType
			]
		ifNone: [ 
			ObjectNotFound signal:
				( 'There''s no plugin "<1s>" enabled.' expandMacrosWith: anOperationalPluginType endpoint)
			]
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> enable: anOperationalPluginType [

	disabledOperationalPlugins
		detect: [ :plugin | plugin endpoint = anOperationalPluginType endpoint ]
		ifFound: [ :pluginToEnable | 
			self
				markAsEnabled: pluginToEnable;
				withConfigurationOf: pluginToEnable
				do: [ :configuration | configuration at: #enabled put: true ]
				ifAbsent: [  ];
				configureRoutesDeclaredByPlugin: anOperationalPluginType
			]
		ifNone: [ 
			ObjectNotFound signal:
				( 'There''s no plugin "<1s>" disabled.' expandMacrosWith: anOperationalPluginType endpoint )
			]
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> enable: anOperationalPluginEndpoint configuredBy: configuration [

	| pluginToEnable |

	pluginToEnable := ( OperationalPlugin pluginAt: anOperationalPluginEndpoint )
		configuredBy: configuration.
	enabledOperationalPlugins add: pluginToEnable.
	pluginToEnable includeControllersIn: self
]

{ #category : 'initialization' }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aRESTfulControllerCollection [

	optionalCORSHandler := Optional unusedBecause: 'CORS not configured'.
	teapotServer := Teapot
		configure: configuration , {( #notFoundHandlerClass -> Tea405AwareNotFoundHandler )}.
	operationsConfiguration := configuration asDictionary at: #operations.
	self
		initializeControllersWithAll: aRESTfulControllerCollection;
		initializeErrorHandlers;
		initializeEnabledOperationalPlugins
]

{ #category : 'initialization' }
HTTPBasedRESTfulAPI >> initializeControllersWithAll: aRESTfulControllerCollection [

	controllers := OrderedCollection with: ( OperationalPluginsRESTfulController on: self ).
	controllers addAll: aRESTfulControllerCollection
]

{ #category : 'initialization' }
HTTPBasedRESTfulAPI >> initializeEnabledOperationalPlugins [

	enabledOperationalPlugins := OrderedSet new.
	disabledOperationalPlugins := OrderedSet new.
	OperationalPlugin availablePlugins
		select: [ :plugin | 
			self withConfigurationOf: plugin
				do: [ :pluginConfiguration |
				pluginConfiguration at: #enabled ifAbsent: [ plugin enabledByDefault ] ]
				ifAbsent: [ plugin enabledByDefault ]
			]
		thenDo: [ :plugin | self enable: plugin endpoint configuredBy: operationsConfiguration ]
]

{ #category : 'initialization' }
HTTPBasedRESTfulAPI >> initializeErrorHandlers [

	errorHandlers := OrderedCollection new.
	self on: HTTPClientError addErrorHandler: [ :clientError :request |
		| json response |

		json := NeoJSONWriter toStringPretty: clientError.
		response := ZnResponse statusCode: clientError code.
		response entity: ( ZnEntity json: json ).
		self applyCrossSharingResourceConfigurationTo: response accordingTo: request.
		response
		]
]

{ #category : 'actions' }
HTTPBasedRESTfulAPI >> install [

	self
		configureRoutes;
		configureErrorHandlers
]

{ #category : 'testing' }
HTTPBasedRESTfulAPI >> isEnabled: aPluginType [

	^ enabledOperationalPlugins anySatisfy: [ :plugin | plugin isA: aPluginType ]
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> markAsDisabled: plugin [

	plugin stop.
	enabledOperationalPlugins remove: plugin ifAbsent: [  ].
	disabledOperationalPlugins add: plugin
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> markAsEnabled: plugin [

	disabledOperationalPlugins remove: plugin ifAbsent: [  ].
	enabledOperationalPlugins add: plugin.
	plugin startOn: teapotServer
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> on: exception addErrorHandler: aDyadicBlock [

	errorHandlers add: exception -> aDyadicBlock
]

{ #category : 'accessing' }
HTTPBasedRESTfulAPI >> operationsConfiguration [

	^ operationsConfiguration
]

{ #category : 'configuring' }
HTTPBasedRESTfulAPI >> removeRoutesDeclaredByPlugin: anOperationalPluginType [

	^ self withControllersDefinedByPlugin: anOperationalPluginType do: [ :controller | 
		  controller routes do: [ :routeSpecification | 
			  teapotServer removeRoutesMatchedBy: routeSpecification asRequestMatcher ]
		  ]
]

{ #category : 'actions' }
HTTPBasedRESTfulAPI >> start [

	enabledOperationalPlugins do: [ :plugin | plugin startOn: teapotServer ].
	teapotServer start
]

{ #category : 'actions' }
HTTPBasedRESTfulAPI >> stop [

	teapotServer stop.
	enabledOperationalPlugins do: #stop
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> withConfigurationOf: plugin do: aPresentBlock ifAbsent: anAbsentBlock [

	^ operationsConfiguration at: plugin endpoint ifPresent: aPresentBlock ifAbsent: anAbsentBlock
]

{ #category : 'private - configuring' }
HTTPBasedRESTfulAPI >> withControllersDefinedByPlugin: anOperationalPluginType do: aBlock [

	controllers
		select: [ :controller | 
			( controller respondsTo: #pluginEndpoint ) and: [ 
				controller pluginEndpoint = anOperationalPluginType endpoint ]
			]
		thenDo: aBlock
]
