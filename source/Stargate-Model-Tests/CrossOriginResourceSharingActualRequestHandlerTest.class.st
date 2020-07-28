Class {
	#name : #CrossOriginResourceSharingActualRequestHandlerTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-CORS'
}

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> requestOriginatedAt: origin [

	| request |

	request := ZnRequest options: '/devices' asUrl.
	request headers at: 'Origin' put: origin.

	^ TeaRequest fromZnRequest: request
]

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowingAnyOrigin [

	| handler request response |
	
	handler := CrossOriginResourceSharingActualRequestHandlerBuilder new
		allowAnyOrigin;
		build.

	request := self requestOriginatedAt: 'http://localhost:65000'.
	response := ZnResponse created: 'http://localhost:65000' asUrl.

	handler teaEvalActionOnRequest: request response: response.

	self
		assert: response code equals: 201;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		should: [ response headers at: 'Vary' ] raise: KeyNotFound
]

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowingCredentials [

	| handler request response |

	handler := CrossOriginResourceSharingActualRequestHandlerBuilder new
		allowAnyOrigin;
		allowCredentials;
		build.

	request := self requestOriginatedAt: 'http://localhost:65000'.
	response := ZnResponse noContent.

	handler teaEvalActionOnRequest: request response: response.

	self
		assert: response code equals: 204;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		assert: ( response headers at: 'Access-Control-Allow-Credentials' ) equals: 'true';
		should: [ response headers at: 'Vary' ] raise: KeyNotFound
]

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowingExactlyOneOrigin [

	| handler request response |

	handler := CrossOriginResourceSharingActualRequestHandlerBuilder new 
		allowOnlyFrom: {'http://localhost:65000/' asUrl};
		build.
	
	request := self requestOriginatedAt: 'http://localhost:65000'.
	response := ZnResponse noContent.

	handler teaEvalActionOnRequest: request response: response.

	self
		assert: response code equals: 204;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: 'http://localhost:65000/';
		should: [ response headers at: 'Vary' ] raise: KeyNotFound
]

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> testAllowingMoreThanOneOrigin [

	| handler request response |

	handler := CrossOriginResourceSharingActualRequestHandlerBuilder new
		allowOnlyFrom:
			{'http://localhost:65000/' asUrl.
			'http://google.com/' asUrl};
		build.

	request := self requestOriginatedAt: 'http://localhost:65000'.
	response := ZnResponse noContent.

	handler teaEvalActionOnRequest: request response: response.
	self
		assert: response code equals: 204;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: 'http://localhost:65000/';
		assert: ( response headers at: 'Vary' ) equals: 'Origin'
]

{ #category : #tests }
CrossOriginResourceSharingActualRequestHandlerTest >> testExposingHeaders [

	| handler request response |

	handler := CrossOriginResourceSharingActualRequestHandlerBuilder new
		allowAnyOrigin
		expose: #('Authorization' 'X-Custom');
		build.
		
	request := self requestOriginatedAt: 'http://localhost:65000'.
	response := ZnResponse noContent.

	handler teaEvalActionOnRequest: request response: response.
	self
		assert: response code equals: 204;
		assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*';
		assert: ( response headers at: 'Access-Control-Expose-Headers' )
			equals: 'Authorization, X-Custom'
]
