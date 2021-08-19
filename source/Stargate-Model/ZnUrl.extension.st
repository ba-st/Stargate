Extension { #name : #ZnUrl }

{ #category : #'*Stargate-Model' }
ZnUrl >> hasValidOrigin [

	^ WebOrigin hasValidOrigin: self
]

{ #category : #'*Stargate-Model' }
ZnUrl >> origin [

	^ WebOrigin basedOn: self 
]
