Class {
	#name : 'CrossOriginResourceSharingActualRequestHandlerTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-CORS',
	#package : 'Stargate-Model-Tests',
	#tag : 'CORS'
}

{ #category : 'tests - support' }
CrossOriginResourceSharingActualRequestHandlerTest >> assert: aResponse canBeSharedWithRequestsFrom: anOriginLocation [

	self
		assert: ( aResponse headers at: 'Access-Control-Allow-Origin' )
		equals: anOriginLocation asWebOrigin asString
]

{ #category : 'tests - support' }
CrossOriginResourceSharingActualRequestHandlerTest >> assert: aHandlerBuilderConfiguration handles: aRequest byResponding: responseAssertions [

	| handler response |

	handler := self
		crossOriginResourceSharingActualRequestHandlerBuilderApplying: aHandlerBuilderConfiguration.
	response := ZnResponse created: self serverLocation asUrl / 'devices' / '1'.
	handler teaEvalActionOnRequest: aRequest response: response.
	responseAssertions value: response
]

{ #category : 'tests - support' }
CrossOriginResourceSharingActualRequestHandlerTest >> crossOriginResourceSharingActualRequestHandlerBuilderApplying: aHandlerBuilderConfigurationBlock [

	| handlerBuilder |

	handlerBuilder := CrossOriginResourceSharingActualRequestHandlerBuilder new.
	aHandlerBuilderConfigurationBlock value: handlerBuilder.
	^ handlerBuilder build
]

{ #category : 'tests - support' }
CrossOriginResourceSharingActualRequestHandlerTest >> postRequestOriginatedAt: origin [

	| request |

	request := ZnRequest post: self serverLocation / 'devices' asUrl.
	request headers at: 'Origin' put: origin.

	^ TeaRequest fromZnRequest: request
]

{ #category : 'accessing' }
CrossOriginResourceSharingActualRequestHandlerTest >> serverLocation [

	^ 'http://server.com' asUrl 
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowAnyOrigin [

	| request |

	request := self postRequestOriginatedAt: self websiteLocation.

	self
		assert: [ :handler | handler allowAnyOrigin ]
		handles: request
		byResponding: [ :response | 
			self
				assert: response isCreated;
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				should: [ response headers at: 'Vary' ] raise: KeyNotFound
			]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowCredentials [

	| request |

	request := self postRequestOriginatedAt: self websiteLocation.

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				allowCredentials
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response isCreated;
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
				should: [ response headers at: 'Vary' ] raise: KeyNotFound
			]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowExactlyOneOrigin [

  | request |
  request := self postRequestOriginatedAt: self websiteLocation.

  self
    assert: [ :handler | handler allowOnlyFrom: { self websiteLocation } ]
    handles: request
    byResponding: [ :response |
        self
          assert: response isCreated;
          assert: response canBeSharedWithRequestsFrom: self websiteLocation;
          assert: ( response headers at: 'Vary' ) equals: 'Origin'
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowMoreThanOneOrigin [

	| request |

	request := self postRequestOriginatedAt: self websiteLocation.

	self
		assert: [ :handler | 
			handler
				allowOnlyFrom:
					{self websiteLocation.
					'http://google.com/' asUrl}
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response isCreated;
				assert: response canBeSharedWithRequestsFrom: self websiteLocation;
				assert: ( response headers at: 'Vary' ) equals: 'Origin'
			]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testApplyingTwiceDoesNotRepeatHeaders [

  | handler request response |
  handler := self crossOriginResourceSharingActualRequestHandlerBuilderApplying: [ :builder |
                 builder
                   allowOnlyFrom: { self websiteLocation . 'http://google.com/' asUrl };
                   expose: #( 'Authorization' 'X-Custom' )
               ].
  request := self postRequestOriginatedAt: self websiteLocation.
  response := ZnResponse created: self serverLocation asUrl / 'devices' / '1'.

  handler
    teaEvalActionOnRequest: request response: response;
    teaEvalActionOnRequest: request response: response.

  self
    assert: response canBeSharedWithRequestsFrom: self websiteLocation;
    assert: ( response headers at: 'Vary' ) equals: 'Origin';
    assert: ( response headers at: 'Access-Control-Expose-Headers' )
    equals: 'Authorization, X-Custom'
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testExposeHeaders [

	| request |

	request := self postRequestOriginatedAt: self websiteLocation.

	self
		assert: [ :handler | 
			handler
				allowAnyOrigin;
				expose: #('Authorization' 'X-Custom')
			]
		handles: request
		byResponding: [ :response | 
			self
				assert: response isCreated;
				assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
				assert: ( response headers at: 'Access-Control-Expose-Headers' )
					equals: 'Authorization, X-Custom'
			]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testExposeHeadersEndingWithAnotherExposedHeader [

  self
    assert: [ :handler |
        handler
          allowAnyOrigin;
          expose: #( 'X-Authorization' 'Authorization' )
      ]
    handles: ( self postRequestOriginatedAt: self websiteLocation )
    byResponding: [ :response |
        self
          assert: ( response headers at: 'Access-Control-Expose-Headers' )
          equals: 'X-Authorization, Authorization'
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testIgnoreRequestsWithoutOrigin [

  self
    assert: [ :handler |
        handler
          allowAnyOrigin;
          allowCredentials;
          expose: #( 'Authorization' )
      ]
    handles: ( TeaRequest fromZnRequest: ( ZnRequest post: self serverLocation / 'devices' asUrl ) )
    byResponding: [ :response |
        self
          assert: response isCreated;
          should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound;
          should: [ response headers at: 'Access-Control-Allow-Credentials' ] raise: KeyNotFound;
          should: [ response headers at: 'Access-Control-Expose-Headers' ] raise: KeyNotFound;
          should: [ response headers at: 'Vary' ] raise: KeyNotFound
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testRespondWithEmptyHeadersIfOriginNotAllowed [

  | request handler |
  request := self postRequestOriginatedAt: 'http://www.google.com' asUrl.


  handler := CrossOriginResourceSharingActualRequestHandlerBuilder new
               allowOnlyFrom: { self websiteLocation };
               build.

  self
    should: [ handler teaEvalActionOnRequest: request response: ZnResponse noContent ]
    raise: TeaAbort
    withExceptionDo: [ :signal |
        | response |
        response := signal response.
        self
          assert: response code equals: 204;
          deny: ( response headers includesKey: 'Access-Control-Allow-Origin' );
          assert: ( response headers at: 'Vary' ) equals: 'Origin'
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testVaryByOriginOnRequestsWithoutOriginWhenAllowingExactlyOneOrigin [

  self
    assert: [ :handler | handler allowOnlyFrom: { self websiteLocation } ]
    handles: ( TeaRequest fromZnRequest: ( ZnRequest post: self serverLocation / 'devices' asUrl ) )
    byResponding: [ :response |
        self
          assert: response isCreated;
          deny: ( response headers includesKey: 'Access-Control-Allow-Origin' );
          assert: ( response headers at: 'Vary' ) equals: 'Origin'
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testVaryByOriginOnRequestsWithoutOriginWhenAllowingMoreThanOneOrigin [

  self
    assert: [ :handler |
      handler allowOnlyFrom: { self websiteLocation . 'http://google.com/' asUrl } ]
    handles: ( TeaRequest fromZnRequest: ( ZnRequest post: self serverLocation / 'devices' asUrl ) )
    byResponding: [ :response |
        self
          assert: response isCreated;
          deny: ( response headers includesKey: 'Access-Control-Allow-Origin' );
          assert: ( response headers at: 'Vary' ) equals: 'Origin'
      ]
]

{ #category : 'tests' }
CrossOriginResourceSharingActualRequestHandlerTest >> testVaryByOriginKeepsOtherVaryHeaders [

  | handler response |
  handler := self crossOriginResourceSharingActualRequestHandlerBuilderApplying: [ :builder |
                 builder allowOnlyFrom: { self websiteLocation } ].
  response := ZnResponse created: self serverLocation asUrl / 'devices' / '1'.
  response addToVary: 'Accept'.

  handler
    teaEvalActionOnRequest: ( self postRequestOriginatedAt: self websiteLocation )
    response: response;
    teaEvalActionOnRequest:
      ( TeaRequest fromZnRequest: ( ZnRequest post: self serverLocation / 'devices' asUrl ) )
    response: response.

  self assert: response varyHeaderNames equals: #( 'Accept' 'Origin' )
]

{ #category : 'accessing' }
CrossOriginResourceSharingActualRequestHandlerTest >> websiteLocation [

	^ 'http://website.com' asUrl
]
