Extension { #name : #ZnEntity }

{ #category : #'*Stargate-Zinc-Extensions' }
ZnEntity >> asString [

	^ String streamContents: [ :stream | self printContentsOn: stream ]
]
