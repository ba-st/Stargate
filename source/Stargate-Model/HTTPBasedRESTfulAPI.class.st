"
I represent an HTTP based RESTful API, serving one or more services.
"
Class {
	#name : #HTTPBasedRESTfulAPI,
	#superclass : #Object,
	#instVars : [
		'teapotServer',
		'controllers',
		'errorHandlers'
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
HTTPBasedRESTfulAPI >> crossOriginResourceSharingAfterFilterHandlerAllowing: origins [

	^ CrossOriginResourceSharingAfterFilter allowing: origins
]

{ #category : #initialization }
HTTPBasedRESTfulAPI >> initializeConfiguredBy: configuration installing: aRESTfulControllerCollection [

	teapotServer := Teapot configure: configuration , {(#notFoundHandlerClass -> Tea405AwareNotFoundHandler)}.
	controllers := aRESTfulControllerCollection.
	errorHandlers := OrderedCollection new.
	
	self
		on: HTTPClientError
		addErrorHandler: [ :clientError :request | 
			| json |

			json := NeoJSONWriter toStringPretty: clientError.
			(ZnResponse statusCode: clientError code)
				headers:
							(ZnHeaders defaultResponseHeaders
								at: 'Access-Control-Allow-Origin' put: '*';
								yourself);
				entity: (ZnEntity json: json);
				yourself ]
]

{ #category : #actions }
HTTPBasedRESTfulAPI >> install [

	self
		configureRoutes;
		configureErrorHandlers
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
