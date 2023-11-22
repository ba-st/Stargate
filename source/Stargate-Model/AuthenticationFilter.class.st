"
I'm an abstract class representing an authentication filter to be applied as a before filter and perform an auth validation. I will take into consideration the Authorization header on the request and return a 401 / Unauthorized in case the credentials are invalid.
"
Class {
	#name : 'AuthenticationFilter',
	#superclass : 'Object',
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'instance creation' }
AuthenticationFilter class >> basedOn: configuration [

	^ self allSubclasses
		detect: [ :class | class canHandle: configuration ]
		ifFound: [ :subclass | subclass configuredBy: configuration ]
		ifNone: [ self signalMissingConfiguration ]
]

{ #category : 'private' }
AuthenticationFilter class >> canHandle: configuration [

	^ self subclassResponsibility
]

{ #category : 'private' }
AuthenticationFilter class >> configuredBy: configuration [

	^ self subclassResponsibility
]

{ #category : 'private' }
AuthenticationFilter class >> signalMissingConfiguration [

	^ ObjectNotFound signal: 'Missing authentication configuration'
]

{ #category : 'accessing' }
AuthenticationFilter >> authChallenge [

	^ self subclassResponsibility
]

{ #category : 'private' }
AuthenticationFilter >> checkCredentials: authorization for: httpRequest within: requestContext ifInvalid: aBlock [

	self subclassResponsibility
]

{ #category : 'evaluating' }
AuthenticationFilter >> evaluateActionOnRequest: httpRequest within: requestContext [

	| authorization |

	authorization := httpRequest headers
		at: 'Authorization'
		ifAbsent: [ httpRequest abort: ( ZnResponse unauthorized: self authChallenge ) ].
	self
		checkCredentials: authorization
		for: httpRequest
		within: requestContext
		ifInvalid: [ httpRequest abort: ( ZnResponse unauthorized: self authChallenge ) ]
]

{ #category : 'evaluating' }
AuthenticationFilter >> teaEvalActionOnRequest: httpRequest [

	self evaluateActionOnRequest: httpRequest within: HttpRequestContext new
]
