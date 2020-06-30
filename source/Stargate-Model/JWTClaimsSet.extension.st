Extension { #name : #JWTClaimsSet }

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions [

	^ claims at: 'permissions' ifAbsent: [ ^ #() ]
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions: aCollection [

	self at: 'permissions' put: aCollection asArray
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope [

	^ claims at: 'scope' ifAbsent: [ '' ]
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope: aString [

	self at: 'scope' put: aString
]
