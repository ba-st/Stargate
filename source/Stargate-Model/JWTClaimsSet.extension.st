Extension { #name : #JWTClaimsSet }

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> at: aKey ifAbsent: aBlock [

	^ claims at: aKey ifAbsent: aBlock
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions [

	^ self at: 'permissions' ifAbsent: [ ^ #() ]
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions: aCollection [

	self at: 'permissions' put: aCollection asArray
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope [

	^ self at: 'scope' ifAbsent: [ '' ]
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope: aString [

	self at: 'scope' put: aString
]
