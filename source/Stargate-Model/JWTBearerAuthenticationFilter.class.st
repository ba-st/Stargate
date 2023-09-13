"
I'm an authentication filter using Bearer tokens in JWT format
"
Class {
	#name : #JWTBearerAuthenticationFilter,
	#superclass : #AuthenticationFilter,
	#instVars : [
		'key',
		'algorithm'
	],
	#category : #'Stargate-Model-Auth'
}

{ #category : #private }
JWTBearerAuthenticationFilter class >> canHandle: configuration [

	| schema algorithm |
	schema := configuration at: #authSchema ifAbsent: [ ^ false ].
	algorithm := configuration at: #authAlgorithm ifAbsent: [ ^ false ].
	^ schema = 'jwt' and: [
		  algorithm ~= JWANone parameterValue and: [
			  JsonWebAlgorithm supportsAlgorithmNamed: algorithm ] ]
]

{ #category : #private }
JWTBearerAuthenticationFilter class >> configuredBy: configuration [

	^ self
		with: ( configuration at: #authSecret ifAbsent: [ self signalMissingConfiguration ] )
		forAlgorithmNamed: ( configuration at: #authAlgorithm )
]

{ #category : #'instance creation' }
JWTBearerAuthenticationFilter class >> with: aKey forAlgorithmNamed: anAlgorithmName [

	^ self new initializeWith: aKey forAlgorithm: ( JsonWebAlgorithm named: anAlgorithmName )
]

{ #category : #accessing }
JWTBearerAuthenticationFilter >> authChallenge [

	^ 'Bearer'
]

{ #category : #private }
JWTBearerAuthenticationFilter >> checkCredentials: authorization for: httpRequest within: requestContext ifInvalid: aBlock [

	| tokenString |

	( authorization beginsWith: 'Bearer ' )
		ifFalse: aBlock.
	tokenString := authorization allButFirst: 7.
	[ | jws |

	jws := JsonWebSignature materializeCompact: tokenString key: key.
	jws algorithm = algorithm
		ifFalse: aBlock.
	requestContext permissions: jws payload permissions
	]
		on: Error
		do: [ :error | error return: aBlock value ]
]

{ #category : #initialization }
JWTBearerAuthenticationFilter >> initializeWith: aKey forAlgorithm: anAlgorithm [

	key := aKey .
	algorithm := anAlgorithm 
]
