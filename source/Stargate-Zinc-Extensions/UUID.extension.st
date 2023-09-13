Extension { #name : #UUID }

{ #category : #'*Stargate-Zinc-Extensions' }
UUID >> neoJsonOn: neoJSONWriter [

	neoJSONWriter writeString: self printString
]
