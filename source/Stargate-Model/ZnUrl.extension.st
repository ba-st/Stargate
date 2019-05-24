Extension { #name : #ZnUrl }

{ #category : #'*Stargate-Model' }
ZnUrl >> queryAt: aKey putUrl: anUnencodedUrl [

	| encodedUrl |

	encodedUrl := anUnencodedUrl urlEncoded.
	^ self queryAt: aKey put: encodedUrl
]

{ #category : #'*Stargate-Model' }
ZnUrl >> start: startIndex limit: limitCount [

	self
		queryAt: 'start' put: startIndex;
		queryAt: 'limit' put: limitCount
]
