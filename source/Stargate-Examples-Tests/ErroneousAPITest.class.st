Class {
	#name : 'ErroneousAPITest',
	#superclass : 'HTTPBasedRESTfulAPITest',
	#instVars : [
		'controller'
	],
	#category : 'Stargate-Examples-Tests-Server-Errors',
	#package : 'Stargate-Examples-Tests',
	#tag : 'Server-Errors'
}

{ #category : 'asserting' }
ErroneousAPITest >> assert: aResponse canBeSharedWithRequestsFrom: anOriginLocation [

	self
		assert: ( aResponse headers at: 'Access-Control-Allow-Origin' )
		equals: anOriginLocation asWebOrigin asString
]

{ #category : 'running' }
ErroneousAPITest >> configureErrorHandlers [

  api on: ObjectNotFound addErrorHandler: [ :notFound :request |
      ( ZnResponse statusCode: 404 )
        entity: ( ZnEntity with: '{"status":404}' ofType: 'application/problem+json' asMediaType );
        yourself
    ].
  super configureErrorHandlers
]

{ #category : 'private' }
ErroneousAPITest >> controllersToInstall [

	^ { controller }
]

{ #category : 'running' }
ErroneousAPITest >> globalErrorHandler [

	^ [ :error :request |
	  | response |

	  response := ZnResponse serverError: error messageText.
	  api applyCrossSharingResourceConfigurationTo: response accordingTo: request.
	  response
	  ]
]

{ #category : 'running' }
ErroneousAPITest >> setUpAPI [

	controller := ErroneousRESTfulController new.
	super setUpAPI
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAllowingAnyOrigin [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowAnyOrigin ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
                options;
                response.
  self
    assert: response isNoContent;
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
    assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
    assert: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'.


  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 500;
    deny: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*'
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAllowingExactlyOneOrigin [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowOnlyFrom: { self baseUrl } ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
                options;
                response.

  self
    assert: response isNoContent;
    assert: response canBeSharedWithRequestsFrom: self baseUrl;
    assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
    assert: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: response varyHeaderNames includes: 'Origin';
    assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'.

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 500;
    deny: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: response varyHeaderNames includes: 'Origin';
    assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAllowingMoreThanOneOrigin [

  | response |
  api allowCrossOriginSharingApplying: [ :cors |
      cors allowOnlyFrom: { self baseUrl . 'http://google.com/' asUrl } ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
                options;
                response.

  self
    assert: response isNoContent;
    assert: response canBeSharedWithRequestsFrom: self baseUrl;
    assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
    assert: response varyHeaderNames includes: 'Origin';
    assert: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'.

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 500;
    assert: response varyHeaderNames includes: 'Origin';
    deny: response varyHeaderNames includes: 'Access-Control-Request-Headers';
    assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAppliedOnceToErrorResponses [

  | response |
  api allowCrossOriginSharingApplying: [ :cors |
      cors
        allowOnlyFrom: { self baseUrl . 'http://google.com/' asUrl };
        expose: #( 'X-Custom' )
    ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 500;
    assert: ( response varyHeaderNames occurrencesOf: 'Origin' ) equals: 1;
    assert: ( response headers at: 'Access-Control-Expose-Headers' ) equals: 'X-Custom';
    assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAppliedToClientErrorResponses [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowAnyOrigin ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' / 'conflict' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 409;
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*'
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSOptionalHeaders [

  | response |
  api allowCrossOriginSharingApplying: [ :cors |
      cors
        allowAnyOrigin;
        allowCredentials;
        expireIn: 600 seconds;
        expose: #( 'Authorization' 'X-Custom' )
    ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
                options;
                response.

  self
    assert: response isNoContent;
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
    assert: ( response headers at: 'Access-Control-Allow-Headers' ) equals: 'Content-Type';
    assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET';
    assert: ( response headers at: 'Access-Control-Expose-Headers' )
    equals: 'Authorization, X-Custom';
    assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
    assert: ( response headers at: 'Access-Control-Max-Age' ) equals: '600';
    assert: response varyHeaderNames includes: 'Access-Control-Request-Headers'.

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 500;
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
    should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
    should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound;
    assert: ( response headers at: 'Access-Control-Expose-Headers' )
    equals: 'Authorization, X-Custom';
    assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
    should: [ response headers at: 'Access-Control-Max-Age' ] raise: KeyNotFound;
    deny: response varyHeaderNames includes: 'Access-Control-Request-Headers'
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSRespondWithEmptyHeadersIfOriginNotAllowed [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowOnlyFrom: { 'https://google.com' asUrl } ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                headerAt: 'Access-Control-Request-Headers' put: 'Content-Type';
                options;
                response.

  self
    assert: response isNoContent;
    assert: ( response headers at: 'Vary' ) equals: 'Origin';
    should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound;
    should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
    should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound.

  { '1' -> 500 . '1/conflict' -> 409 . '1/not-found' -> 404 } do: [ :pathAndCode |
      response := self newClient
                    url: self baseUrl / 'errors' / pathAndCode key asUrl;
                    headerAt: 'Origin' put: self baseUrl printString;
                    enforceHttpSuccess: false;
                    get;
                    response.

      self
        assert: response code equals: pathAndCode value;
        assert: ( response headers at: 'Vary' ) equals: 'Origin';
        should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound
    ]
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSVaryByOriginOnErrorResponsesToRequestsWithoutOrigin [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowOnlyFrom: { self baseUrl } ].

  #( '1' '1/conflict' '1/not-found' ) do: [ :path |
      response := self newClient
                    url: self baseUrl / 'errors' / path asUrl;
                    enforceHttpSuccess: false;
                    get;
                    response.

      self
        deny: response isSuccess;
        assert: ( response varyHeaderNames occurrencesOf: 'Origin' ) equals: 1;
        deny: ( response headers includesKey: 'Access-Control-Allow-Origin' )
    ]
]

{ #category : 'tests' }
ErroneousAPITest >> testClientErrorsAreHandledBeforeOtherErrors [

  | response |
  response := self newClient
                url: self baseUrl / 'errors' / '1' / 'conflict' asUrl;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 409;
    assert: response contentType equals: ZnMimeType applicationJson
]

{ #category : 'tests' }
ErroneousAPITest >> testSpecificErrorHandler [

  | response |
  response := self newClient
                url: self baseUrl / 'errors' / '1' / 'not-found' asUrl;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 404;
    assert: response contentType equals: 'application/problem+json' asMediaType;
    assert: response contents equals: '{"status":404}'
]
