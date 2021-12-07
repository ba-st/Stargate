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
		'operationsConfiguration',
		'disabledOperationalPlugins'
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
HTTPBasedRESTfulAPI >> allowCrossOriginSharingApplying: aConfigurationBlock [

	| builder |

	builder := aConfigurationBlock
		value: ( CrossOriginResourceSharingFilterBuilder using: controllers ).
	builder buildPreflightFilter applyOn: teapotServer.
	builder buildActualRequestFilter applyOn: teapotServer
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

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutesDeclaredByPlugin: anOperationalPluginEndpoint [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	^ self withControllersDefinedByPlugin: anOperationalPluginEndpoint
		  do: [ :controller | configurator addRoutesOf: controller ]
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> disable: anOperationalPluginEndpoint [

	enabledOperationalPlugins
		detect: [ :plugin | plugin endpoint = anOperationalPluginEndpoint ]
		ifFound: [ :pluginToDisable | 
			self
				markAsDisabled: pluginToDisable;
				withConfigurationOf: pluginToDisable
				do: [ :configuration | configuration at: #enabled put: false ]
				ifAbsent: [  ];
				removeRoutesDeclaredByPlugin: anOperationalPluginEndpoint
			]
		ifNone: [ 
			ObjectNotFound signal:
				( 'There''s no plugin "<1s>" enabled.' expandMacrosWith: anOperationalPluginEndpoint )
			]
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> enable: anOperationalPluginEndpoint [

	disabledOperationalPlugins
		detect: [ :plugin | plugin endpoint = anOperationalPluginEndpoint ]
		ifFound: [ :pluginToEnable | 
			self
				markAsEnabled: pluginToEnable;
				withConfigurationOf: pluginToEnable
				do: [ :configuration | configuration at: #enabled put: true ]
				ifAbsent: [  ];
				configureRoutesDeclaredByPlugin: anOperationalPluginEndpoint
			]
		ifNone: [ 
			ObjectNotFound signal:
				( 'There''s no plugin "<1s>" disabled.' expandMacrosWith: anOperationalPluginEndpoint )
			]
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

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> markAsDisabled: plugin [

	plugin stop.
	enabledOperationalPlugins remove: plugin ifAbsent: [  ].
	disabledOperationalPlugins add: plugin
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> markAsEnabled: plugin [

	disabledOperationalPlugins remove: plugin ifAbsent: [  ].
	enabledOperationalPlugins add: plugin.
	plugin startOn: teapotServer
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> on: exception addErrorHandler: aDyadicBlock [

	errorHandlers add: exception -> aDyadicBlock
]

{ #category : #accessing }
HTTPBasedRESTfulAPI >> operationsConfiguration [

	^ operationsConfiguration
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> removeRoutesDeclaredByPlugin: anOperationalPluginEndpoint [

	^ self withControllersDefinedByPlugin: anOperationalPluginEndpoint do: [ :controller | 
		  controller routes do: [ :routeSpecification | 
			  teapotServer removeRoutesMatchedBy: routeSpecification asRequestMatcher ]
		  ]
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

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> withConfigurationOf: plugin do: aPresentBlock ifAbsent: anAbsentBlock [

	^ operationsConfiguration at: plugin endpoint ifPresent: aPresentBlock ifAbsent: anAbsentBlock
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> withControllersDefinedByPlugin: anOperationalPluginEndpoint do: aBlock [

	controllers
		select: [ :controller | 
			( controller respondsTo: #pluginEndpoint ) and: [ 
				controller pluginEndpoint = anOperationalPluginEndpoint ]
			]
		thenDo: aBlock
]
