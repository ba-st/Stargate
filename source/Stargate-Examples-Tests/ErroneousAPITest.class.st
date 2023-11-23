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
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'.


	response := self newClient
		            url: self baseUrl / 'errors' / '1' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response code equals: 500;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
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
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Origin';
		assert: ( response headers at: 'Access-Control-Allow-Methods' ) equals: 'GET'.

	response := self newClient
		            url: self baseUrl / 'errors' / '1' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response code equals: 500;
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Origin';
		assert: response canBeSharedWithRequestsFrom: self baseUrl
]

{ #category : 'tests' }
ErroneousAPITest >> testCORSAllowingMoreThanOneOrigin [

	| response |

	api allowCrossOriginSharingApplying: [ :cors |
		cors allowOnlyFrom: {
				self baseUrl.
				'http://google.com/' asUrl }
		].

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
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
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
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers';
		assert: response canBeSharedWithRequestsFrom: self baseUrl
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
		assert: response varyHeaderNames includes: 'Access-Control-Allow-Headers'.

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
		deny: response varyHeaderNames includes: 'Access-Control-Allow-Headers'
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
		should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Headers' ] raise: KeyNotFound;
		should: [ response headers at: 'Access-Control-Allow-Methods' ] raise: KeyNotFound.

	response := self newClient
		            url: self baseUrl / 'errors' / '1' asUrl;
		            headerAt: 'Origin' put: self baseUrl printString;
		            enforceHttpSuccess: false;
		            get;
		            response.

	self
		assert: response code equals: 500;
		assert: response varyHeaderNames isEmpty;
		should: [ response headers at: 'Access-Control-Allow-Origin' ] raise: KeyNotFound
]
