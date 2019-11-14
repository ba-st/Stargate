Extension { #name : #ZnSingleThreadedServer }

{ #category : #'*Stargate-Model' }
ZnSingleThreadedServer >> setLogLevelAtLeastTo: integer [

	self logLevel: (integer max: logLevel)
]
