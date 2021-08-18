"
I'm a test case for CrossOriginResourceSharingHandler
"
Class {
	#name : #CrossOriginResourceSharingPreflightHandlerTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-CORS'
}

{ #category : #'tests - support' }
CrossOriginResourceSharingPreflightHandlerTest >> assert: aResponse canBeSharedWithRequestsFrom: anOriginLocation [

	self
		assert: ( aResponse headers at: 'Access-Control-Allow-Origin' )
		equals: anOriginLocation asString allButLast
]

{ #category : #'tests - support' }
CrossOriginResourceSharingPreflightHandlerTest >> assert: aHandlerBuilderConfiguration handles: aRequest byResponding: responseAssertions [

	| handler response |

	handler := self
		crossOriginResourceSharingPreflightHandlerBuilderApplying: aHandlerBuilderConfiguration.

	self
		should: [ handler teaEvalActionOnRequest: aRequest ]
		raise: TeaAbort
		withExceptionDo: [ :signal | 
			response := signal response.
			self
				assert: response isNoContent;
				shouldnt: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound;
				shouldnt: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound.
				
			responseAssertions value: response
			]
]

{ #category : #'tests - support' }
CrossOriginResourceSharingPreflightHandlerTest >> crossOriginResourceSharingPreflightHandlerBuilderApplying: aHandlerBuilderConfigurationBlock [

	| handlerBuilder |

	handlerBuilder := CrossOriginResourceSharingPreflightHandlerBuilder new.
	aHandlerBuilderConfigurationBlock value: handlerBuilder.
	^ handlerBuilder build
]

{ #category : #'tests - support' }
CrossOriginResourceSharingPreflightHandlerTest >> requestOptionsFor: aLocation originatedAt: anOrigin configuringHeadersWith: aBlock [

	| request |

	request := ZnRequest options: aLocation asUrl.
	request headers at: 'Origin' put: anOrigin.

	aBlock value: request headers.

	^ TeaRequest fromZnRequest: request
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowAnyOrigin [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowCredentials [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowMethods: allowedMethods;
				allowCredentials
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowExactlyOneOrigin [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowHeadersMatchRequestHeaders [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type, Authorization' ].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				assert: ( response headers at: 'Access-Control-Allow-Headers' )
					equals: 'Content-Type, Authorization';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowHeadersWithEmptyRequestHeaders [

	| request allowedMethods |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers |  ].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: NotFound;
				should: [ response headers at: 'Vary' ] raise: KeyNotFound
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowMoreThanOneOrigin [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom:
					{self websiteLocation.
					'http://google.com/ asUrl' asUrl};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: response varyHeaderNames equals: #('Origin' 'Access-Control-Allow-Headers');
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowedMethodsReflectsDefinedByRoutes [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET');
		at: '/users' put: #('GET' 'POST' 'PUT');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | 
			headers
				at: 'Access-Control-Request-Headers' put: 'Content-Type';
				at: 'Access-Control-Request-Method' put: 'GET';
				yourself
			].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'
			].

	request := self
		requestOptionsFor: '/users'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | 
			headers
				at: 'Access-Control-Request-Headers' put: 'Content-Type';
				at: 'Access-Control-Request-Method' put: 'POST';
				yourself
			].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert:  response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST, PUT'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testAllowedMethodsReflectsDefinedByRoutesIgnoringRequested [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | 
			headers
				at: 'Access-Control-Request-Headers' put: 'Content-Type';
				at: 'Access-Control-Request-Method' put: 'PUT'
			].

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom: {self websiteLocation};
				allowMethods: allowedMethods
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testDisableCache [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowMethods: allowedMethods;
				doNotCache
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				assert: ( response headers at: 'Access-Control-Max-Age' ) equals: '-1'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testDontHandleIfRouteDoesNotMatch [

	| handler allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		at: '/devices/<id>/configurations' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/pets'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].
 
	handler := CrossOriginResourceSharingPreflightHandlerBuilder new
		allowAnyOrigin;
		allowMethods: allowedMethods;
		build. 
	
	self shouldnt: [ handler teaEvalActionOnRequest: request ] raise: TeaAbort
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testExpireIn [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowMethods: allowedMethods;
				expireIn: 600 seconds
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				assert: ( response headers at: 'Access-Control-Max-Age' ) equals: '600'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testExposeHeaders [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowMethods: allowedMethods;
				expose: #('Authorization' 'X-Custom')
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
				assert: ( response headers at: 'Vary' ) equals: 'Access-Control-Allow-Headers';
				assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET, POST';
				assert: ( response headers at: 'Access-Control-Expose-Headers' )
					equals: 'Authorization, X-Custom'
			]
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testHandlingUrlWithPlaceholders [

	| allowedMethods request |

	allowedMethods := Dictionary new
		at: '/devices/<id>/configurations' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices/4/configurations'
		originatedAt: self websiteLocation
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	self
		should: [
			 ( CrossOriginResourceSharingPreflightHandlerBuilder new
				allowAnyOrigin;
				allowMethods: allowedMethods;
				build )
				teaEvalActionOnRequest: request
			]
		raise: TeaAbort
]

{ #category : #tests }
CrossOriginResourceSharingPreflightHandlerTest >> testRespondWithEmptyHeadersIfOriginNotAllowed [

	| allowedMethods request handler |

	allowedMethods := Dictionary new
		at: '/devices' put: #('GET' 'POST');
		yourself.

	request := self
		requestOptionsFor: '/devices'
		originatedAt: 'http://www.google.com' asUrl
		configuringHeadersWith: [ :headers | headers at: 'Access-Control-Request-Headers' put: 'Content-Type' ].

	handler := CrossOriginResourceSharingPreflightHandlerBuilder new
		allowOnlyFrom: {self websiteLocation};
		allowMethods: allowedMethods;
		build.

	self
		should: [ handler teaEvalActionOnRequest: request ]
		raise: TeaAbort
		withExceptionDo: [ :signal | 
			| response |

			response := signal response.
			self
				assert: response code equals: 204;
				assert: response headers isEmpty
			]
]

{ #category : #accessing }
CrossOriginResourceSharingPreflightHandlerTest >> websiteLocation [

	^ 'http://website.com' asUrl
]
