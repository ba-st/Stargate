Extension { #name : #ZnMimeType }

{ #category : #'*Stargate-REST-API' }
ZnMimeType >> asMediaType [

	^ self
]

{ #category : #'*Stargate-REST-API' }
ZnMimeType >> canAccept: aMimeType [

	^ (aMimeType main = '*' or: [ aMimeType main = self main ])
		and: [ aMimeType sub = '*' or: [ (self sub splitOn: $+) includes: aMimeType sub ] ]
]

{ #category : #'*Stargate-REST-API' }
ZnMimeType >> precedence [

	main = '*'
		ifTrue: [ ^ 1 ].
	sub = '*'
		ifTrue: [ ^ 2 ].
	^ (self isVendorSpecific and: [ sub includes: $+])
		ifTrue: [ 4 ]
		ifFalse: [ 3 ]
]

{ #category : #'*Stargate-REST-API' }
ZnMimeType >> quality [

	^ Float readFrom: (self parameterAt: 'q' ifAbsent: [ ^1.0 ])
]
