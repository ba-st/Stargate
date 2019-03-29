Extension { #name : #TeaRequest }

{ #category : #'*Stargate-Model' }
TeaRequest >> at: key ifPresent: aPresentBlock ifAbsent: anAbsentBlock [

	^ aPresentBlock cull: ( self at: key ifAbsent: [ ^ anAbsentBlock value ] )
]
