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

	^ ZnAuthenticationFilter username: self username password: self password
]

{ #category : #private }
ZnAuthenticationFilterTest >> newHttpRequestWithBasicAuthenticationUsername: username password: password [

	^ ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setBasicAuthenticationUsername: username password: password;
		yourself
]

{ #category : #private }
ZnAuthenticationFilterTest >> password [

	^ 'xxx'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testAuthChallenge [

	self assert: self newFilter authChallenge equals: 'Basic realm=ZincHTTPComponents'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testBasedOnConfiguration [

	| filter |

	filter := AuthenticationFilter
		basedOn:
			( Dictionary new
				at: #authSchema put: 'basic';
				at: #authUsername put: self username;
				at: #authPassword put: self password;
				yourself ).

	self
		assert: ( filter isA: ZnAuthenticationFilter );
		shouldnt: [ filter
				teaEvalActionOnRequest: ( self newHttpRequestWithBasicAuthenticationUsername: self username password: self password )
			]
			raise: TeaAbort
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testInvalidCredentials [

	| filter |

	filter := self newFilter.

	self
		assertResponseFor: ( self newHttpRequestWithBasicAuthenticationUsername: self username password: '' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithBasicAuthenticationUsername: 'julio' password: self password )
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
ZnAuthenticationFilterTest >> testMissingPasswordConfiguration [

	self
		should: [ AuthenticationFilter
				basedOn:
					( Dictionary new
						at: #authSchema put: 'basic';
						at: #authUsername put: self username;
						yourself )
			]
		raise: AssertionFailed
		withMessageText: 'Missing password'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testMissingSchemaConfiguration [

	self
		should: [ AuthenticationFilter basedOn: Dictionary new ]
		raise: ObjectNotFound
		withMessageText: 'Missing authentication configuration'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testMissingUsernameConfiguration [

	self
		should: [ AuthenticationFilter
				basedOn:
					( Dictionary new
						at: #authSchema put: 'basic';
						at: #authPassword put: self password;
						yourself )
			]
		raise: AssertionFailed
		withMessageText: 'Missing username'
]

{ #category : #tests }
ZnAuthenticationFilterTest >> testValidCredentials [

	| filter |

	filter := self newFilter.

	self
		shouldnt: [ filter
				teaEvalActionOnRequest: ( self newHttpRequestWithBasicAuthenticationUsername: self username password: self password )
			]
		raise: TeaAbort
]

{ #category : #private }
ZnAuthenticationFilterTest >> username [

	^ 'admin'
]
