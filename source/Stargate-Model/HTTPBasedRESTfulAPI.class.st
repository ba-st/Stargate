"
I represent an HTTP based RESTful API, serving one or more services.
"
Class {
	#name : #HTTPBasedRESTfulAPI,
	#superclass : #Object,
	#instVars : [
		'teapotServer',
		'controllers'
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
				-> [ :clientError :request | 
					| json |

					json := NeoJSONWriter toStringPretty: clientError.
					(ZnResponse statusCode: clientError code)
						entity: (ZnEntity json: json);
						yourself ]
]

{ #category : #'private - configuring' }
HTTPBasedRESTfulAPI >> configureRoutes [

	| configurator |

	configurator := ReflectiveRoutesConfigurator appliedTo: teapotServer.
	controllers do: [ :controller | configurator addRoutesOf: controller ]
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aRESTfulControllerCollection [

	teapotServer := Teapot
		configure: configuration , {(#notFoundHandlerClass -> Tea405AwareNotFoundHandler)}.
	controllers := aRESTfulControllerCollection
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
