Extension { #name : #ZnUrl }

{ #category : #'*Stargate-Model' }
ZnUrl >> asWebOrigin [

	^ WebOrigin basedOn: self 
]

{ #category : #'*Stargate-Model' }
ZnUrl >> hasValidOrigin [

	^ WebOrigin hasValidOrigin: self
]
