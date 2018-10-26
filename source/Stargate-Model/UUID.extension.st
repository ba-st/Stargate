Extension { #name : #UUID }

{ #category : #'*Stargate-Model' }
UUID >> neoJsonOn: neoJSONWriter [

	neoJSONWriter writeString: self asString
]
