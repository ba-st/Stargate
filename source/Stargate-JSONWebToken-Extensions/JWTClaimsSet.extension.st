Extension { #name : #JWTClaimsSet }

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JWTClaimsSet >> at: aKey ifAbsent: aBlock [

	^ claims at: aKey ifAbsent: aBlock
]

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JWTClaimsSet >> permissions [

	^ self at: 'permissions' ifAbsent: [ ^ #() ]
]

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JWTClaimsSet >> permissions: aCollection [

	self at: 'permissions' put: aCollection asArray
]

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JWTClaimsSet >> scope [

	^ self at: 'scope' ifAbsent: [ '' ]
]

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JWTClaimsSet >> scope: aString [

	self at: 'scope' put: aString
]
