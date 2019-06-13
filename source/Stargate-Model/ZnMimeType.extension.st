Extension { #name : #ZnMimeType }

{ #category : #'*Stargate-Model' }
ZnMimeType >> accepts: aMimeType [

	^ (aMimeType main = '*' or: [ aMimeType main = self main ])
		and: [ aMimeType sub = '*'
				or: [ self sub = aMimeType sub or: [ (self sub splitOn: $+) includes: aMimeType sub ] ] ]
]

{ #category : #'*Stargate-Model' }
ZnMimeType >> asMediaType [

	^ self
]

{ #category : #'*Stargate-Model' }
ZnMimeType >> quality [

	^ Float readFrom: (self parameterAt: 'q' ifAbsent: [ ^1.0 ])
]

{ #category : #'*Stargate-Model' }
ZnMimeType >> version: aVersionString [

	self parameters at: 'version' put: aVersionString
]
