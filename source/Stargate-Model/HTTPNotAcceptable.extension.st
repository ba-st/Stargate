Extension { #name : #HTTPNotAcceptable }

{ #category : #'*Stargate-Model' }
HTTPNotAcceptable >> neoJsonOn: neoJSONWriter [

	(neoJSONWriter customMappingFor: ZnMimeType) encoder: [ :mediaType | mediaType asString ].
	neoJSONWriter
		writeMap:
			{(#code -> self code).
			(#message -> self messageText).
			(#allowedMediaTypes -> self allowedMediaTypes)} asDictionary
]
