Extension { #name : #HTTPNotAcceptable }

{ #category : #'*Stargate-Model' }
HTTPNotAcceptable >> neoJsonOn: neoJSONWriter [

	( neoJSONWriter customMappingFor: ZnMimeType ) encoder: [ :mediaType | mediaType asString ].
	( neoJSONWriter customMappingFor: LanguageTag ) encoder: [ :languageTag | languageTag asString ].
	neoJSONWriter
		writeMap:
			( Dictionary new
				at: #code put: self code;
				at: #message put: self messageText;
				at: #allowedMediaTypes put: self allowedMediaTypes;
				at: #allowedLanguageTags put: self allowedLanguageTags;
				yourself )
]
