Extension { #name : #ZnUrl }

{ #category : #'*Stargate-Zinc-Extensions' }
ZnUrl >> asWebOrigin [

	^ WebOrigin basedOn: self 
]

{ #category : #'*Stargate-Zinc-Extensions' }
ZnUrl >> hasValidOrigin [

	^ WebOrigin hasValidOrigin: self
]
