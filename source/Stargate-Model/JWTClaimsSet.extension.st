Extension { #name : #JWTClaimsSet }

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions [

	^ self scope splitOn: Character space
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> permissions: aStringCollection [

	self
		scope:
			( String
				streamContents:
					[ :stream | aStringCollection do: [ :string | stream nextPutAll: string ] separatedBy: [ stream space ] ] )
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope [

	^ claims at: 'scope' ifAbsent: [ '' ]
]

{ #category : #'*Stargate-Model' }
JWTClaimsSet >> scope: aString [

	self at: 'scope' put: aString
]
