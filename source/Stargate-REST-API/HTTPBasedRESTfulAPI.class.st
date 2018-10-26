"
I represent an HTTP based RESTful API, serving one or more services.
"
Class {
	#name : #HTTPBasedRESTfulAPI,
	#superclass : #Object,
	#instVars : [
		'teapotServer',
		'services'
	],
	#category : #'Stargate-REST-API-Services'
}

{ #category : #'instance creation' }
HTTPBasedRESTfulAPI class >> configuredBy: configuration installing: aServicesCollection [

	AssertionChecker enforce: [ aServicesCollection notEmpty ] because: 'An API needs at least to expose one service'.
	^ self new initializeConfiguredBy: configuration installing: aServicesCollection
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> beCORSAwareAllowing: origins [

	teapotServer
		after:
			'/*'
				-> [ :request :response | 
					| requestOrigin requestOriginUrl |

					requestOrigin := request headers at: 'Origin'.
					requestOriginUrl := requestOrigin asUrl.
					origins
						detect: [ :origin | origin = requestOriginUrl ]
						ifFound: [ :allowedOrigin | 
							response headers
								at: 'Access-Control-Allow-Origin' put: requestOrigin;
								at: 'Vary' put: 'Origin' ].
					response ];
		when: [ :request | request headers includesKey: 'Origin' ]
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureHttpClientErrorHandler [

	teapotServer
		exception:
			HTTPClientError
				-> [ :error :request | 
					| json |
					json := STONJSON
						toStringPretty:
							{(#code -> error code).
							(#message -> error messageText)} asDictionary.
					(ZnResponse statusCode: error code)
						entity: (ZnEntity json: json);
						yourself ]
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutes [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	services do: [ :service | configurator addRoutesOf: service ]
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aServicesCollection [

	teapotServer := Teapot configure: configuration.
	services := aServicesCollection
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> install [

	self
		configureRoutes;
		configureHttpClientErrorHandler
]

{ #category : #configuring }
HTTPBasedRESTfulAPI >> on: exception addErrorHandler: aDyadicBlock [

	teapotServer exception: exception -> aDyadicBlock
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> start [

	teapotServer start
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> stop [

	teapotServer stop
]
