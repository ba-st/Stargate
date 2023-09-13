Extension { #name : #TeaRequest }

{ #category : #'*Stargate-Teapot-Extensions' }
TeaRequest >> at: key ifPresent: aPresentBlock ifAbsent: anAbsentBlock [

	^ aPresentBlock cull: ( self at: key ifAbsent: [ ^ anAbsentBlock value ] )
]
