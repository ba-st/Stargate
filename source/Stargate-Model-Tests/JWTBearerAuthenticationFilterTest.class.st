"
A JWTBearerAuthenticationFilterTest is a test class for testing the behavior of JWTBearerAuthenticationFilter
"
Class {
	#name : #JWTBearerAuthenticationFilterTest,
	#superclass : #AuthenticationFilterTest,
	#category : #'Stargate-Model-Tests-Auth'
}

{ #category : #private }
JWTBearerAuthenticationFilterTest >> algorithmName [

	^ JWAHMACSHA256 parameterValue
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> newFilter [

	^ JWTBearerAuthenticationFilter with: self secret forAlgorithmNamed: self algorithmName
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> newHttpRequestWithJWTBearerAuthenticationFor: aKey [

	^ ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: ( 'Bearer <1s>' expandMacrosWith: ( self tokenWithKey: aKey ) );
		yourself
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> newHttpRequestWithJWTBearerAuthenticationScrappingSignatureFor: aKey [

	| strippedToken |

	strippedToken := '.' join: ( ( self tokenWithKey: aKey ) substrings: '.' ) allButLast.

	^ ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: ( 'Bearer <1s>' expandMacrosWith: strippedToken );
		yourself
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> newHttpRequestWithUnsecuredJWTBearerAuthenticationFor: aKey [

	^ ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: ( 'Bearer <1s>' expandMacrosWith: ( self unsecuredTokenWithKey: aKey ) );
		yourself
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> secret [

	^ 'secret'
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testAuthChallenge [

	self assert: self newFilter authChallenge equals: 'Bearer'
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testBasedOnConfiguration [

	| filter |

	filter := AuthenticationFilter
		basedOn:
			( Dictionary new
				at: #authSchema put: 'jwt';
				at: #authAlgorithm put: self algorithmName;
				at: #authSecret put: self secret;
				yourself ).

	self
		assert: ( filter isA: JWTBearerAuthenticationFilter );
		shouldnt: [ filter teaEvalActionOnRequest: ( self newHttpRequestWithJWTBearerAuthenticationFor: self secret ) ]
			raise: TeaAbort
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testInvalidCredentials [

	| filter |

	filter := self newFilter.

	self
		assertResponseFor: ( self newHttpRequestWithJWTBearerAuthenticationFor: '' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithJWTBearerAuthenticationScrappingSignatureFor: self secret )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithUnsecuredJWTBearerAuthenticationFor: self secret )
		isUnauthorizedAfterApplying: filter
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testInvalidType [

	| filter httpRequest |

	filter := self newFilter.
	httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: 'Basic admin:xxx';
		yourself.
	self assertResponseFor: httpRequest isUnauthorizedAfterApplying: filter
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testMissingAlgorithmConfiguration [

	self
		should: [ AuthenticationFilter
				basedOn:
					( Dictionary new
						at: #authSchema put: 'jwt';
						at: #authSecret put: self secret;
						yourself )
			]
		raise: ObjectNotFound
		withMessageText: 'Missing authentication configuration'
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testMissingSecretConfiguration [

	self
		should: [ AuthenticationFilter
				basedOn:
					( Dictionary new
						at: #authSchema put: 'jwt';
						at: #authAlgorithm put: self algorithmName;
						yourself )
			]
		raise: ObjectNotFound
		withMessageText: 'Missing authentication configuration'
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testValidCredentials [

	| filter |

	filter := self newFilter.

	self
		shouldnt:
			[ filter teaEvalActionOnRequest: ( self newHttpRequestWithJWTBearerAuthenticationFor: self secret ) ]
		raise: TeaAbort
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> tokenWithKey: aKey [

	| jws |

	jws := JsonWebSignature new
		algorithmName: self algorithmName;
		payload: JWTClaimsSet new.

	jws key: aKey.

	^ jws compactSerialized
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> unsecuredTokenWithKey: aKey [

	| jws |

	jws := JsonWebSignature new
		algorithmName: 'none';
		payload: JWTClaimsSet new.

	jws key: aKey.

	^ jws compactSerialized
]
