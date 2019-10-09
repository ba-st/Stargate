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

{ #category : #'instance creation' }
JWTBearerAuthenticationFilter class >> with: aKey forAlgorithmNamed: anAlgorithmName [

	^ self new initializeWith: aKey forAlgorithm: ( JsonWebAlgorithm named: anAlgorithmName )
]

{ #category : #accessing }
JWTBearerAuthenticationFilter >> authChallenge [

	^ 'Bearer'
]

{ #category : #private }
JWTBearerAuthenticationFilter >> checkCredentials: authorization for: httpRequest ifInvalid: aBlock [

	| tokenString |

	( authorization beginsWith: 'Bearer ' )
		ifFalse: aBlock.
	tokenString := authorization allButFirst: 7.
	[ | jws |

	jws := JsonWebSignature materializeCompact: tokenString key: key.
	jws algorithm = algorithm
		ifFalse: aBlock
	]
		on: Error
		do: [ :error | error return: aBlock value ]
]

{ #category : #initialization }
JWTBearerAuthenticationFilter >> initializeWith: aKey forAlgorithm: anAlgorithm [

	key := aKey .
	algorithm := anAlgorithm 
]
