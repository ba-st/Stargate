Extension { #name : #UUID }

{ #category : #'*Stargate-REST-API' }
UUID >> neoJsonOn: neoJSONWriter [

	neoJSONWriter writeString: self asString
]
