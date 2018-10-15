Extension { #name : #ZnEntity }

{ #category : #'*Stargate-REST-API' }
ZnEntity class >> json: json [

	^ self stringEntityClass json: json
]

{ #category : #'*Stargate-REST-API' }
ZnEntity class >> with: anObject ofType: aMimeType [

	| entity |

	entity := (self concreteSubclassForType: aMimeType binary: aMimeType isBinary) type: aMimeType.
	aMimeType isBinary
		ifTrue: [ entity bytes: anObject ]
		ifFalse: [ entity string: anObject ].
	^ entity
]
