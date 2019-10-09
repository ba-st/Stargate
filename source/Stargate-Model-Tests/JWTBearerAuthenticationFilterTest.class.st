"
A JWTBearerAuthenticationFilterTest is a test class for testing the behavior of JWTBearerAuthenticationFilter
"
Class {
	#name : #JWTBearerAuthenticationFilterTest,
	#superclass : #AuthenticationFilterTest,
	#category : #'Stargate-Model-Tests-Auth'
}

{ #category : #private }
JWTBearerAuthenticationFilterTest >> newFilter [

	^ JWTBearerAuthenticationFilter with: 'secret' forAlgorithmNamed: 'HS256'
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

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testAuthChallenge [

	self assert: self newFilter authChallenge equals: 'Bearer'
]

{ #category : #tests }
JWTBearerAuthenticationFilterTest >> testInvalidCredentials [

	| filter |

	filter := self newFilter.

	self
		assertResponseFor: ( self newHttpRequestWithJWTBearerAuthenticationFor: '' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithJWTBearerAuthenticationScrappingSignatureFor: 'secret' )
		isUnauthorizedAfterApplying: filter.

	self
		assertResponseFor: ( self newHttpRequestWithUnsecuredJWTBearerAuthenticationFor: 'secret' )
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
JWTBearerAuthenticationFilterTest >> testValidCredentials [

	| filter |

	filter := self newFilter.

	self
		shouldnt:
			[ filter teaEvalActionOnRequest: ( self newHttpRequestWithJWTBearerAuthenticationFor: 'secret' ) ]
		raise: TeaAbort
]

{ #category : #private }
JWTBearerAuthenticationFilterTest >> tokenWithKey: aKey [

	| jws |

	jws := JsonWebSignature new
		algorithmName: 'HS256';
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
