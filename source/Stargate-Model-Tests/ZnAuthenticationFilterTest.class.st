"
A ZnAuthenticationFilterTest is a test class for testing the behavior of ZnAuthenticationFilter
"
Class {
	#name : #ZnAuthenticationFilterTest,
	#superclass : #AuthenticationFilterTest,
	#category : #'Stargate-Model-Tests-Auth'
}

{ #category : #private }
ZnAuthenticationFilterTest >> newFilter [

	^ ZnAuthenticationFilter username: 'admin' password: 'xxx'
]

{ #category : #private }
ZnAuthenticationFilterTest >> newHttpRequestWithBasicAuthenticationUsername: username password: password [

	^ ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setBasicAuthenticationUsername: username password: password;
		yourself
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testAuthChallenge [

	self assert: self newFilter authChallenge equals: 'Basic realm=ZincHTTPComponents'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testInvalidCredentials [

	| filter |

	filter := self newFilter.

	self
		assertResponseFor: ( self newHttpRequestWithBasicAuthenticationUsername: 'admin' password: '' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithBasicAuthenticationUsername: 'julio' password: 'xxx' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithBasicAuthenticationUsername: '' password: '' )
		isUnauthorizedAfterApplying: filter
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testInvalidType [

	| filter httpRequest |

	filter := self newFilter.
	httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: 'Bearer bla-bla-bla';
		yourself.
	self assertResponseFor: httpRequest isUnauthorizedAfterApplying: filter
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testValidCredentials [

	| filter |

	filter := self newFilter.

	self
		shouldnt: [ filter
				teaEvalActionOnRequest: ( self newHttpRequestWithBasicAuthenticationUsername: 'admin' password: 'xxx' )
			]
		raise: TeaAbort
]
