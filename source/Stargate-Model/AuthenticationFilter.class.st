"
I'm an abstract class representing an authentication filter to be applied as a before filter and perform an auth validation. I will take into consideration the Authorization header on the request and return a 401 / Unauthorized in case the credentials are invalid.
"
Class {
	#name : 'AuthenticationFilter',
	#superclass : 'SecurityFilter',
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

{ #category : 'testing' }
AuthenticationFilter class >> isAbstract [

  <ignoreForCoverage>
  ^ self = AuthenticationFilter
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
AuthenticationFilter >> signalMissingAuthorizationHeader [

  ^ HTTPUnauthorized signal: 'Unauthorized' with: self authChallenge
]
