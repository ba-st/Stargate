Extension { #name : 'HTTPNotAcceptable' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPNotAcceptable >> neoJsonOn: neoJSONWriter [

  ( neoJSONWriter customMappingFor: ZnMimeType ) encoder: [ :mediaType | mediaType asString ].
  ( neoJSONWriter customMappingFor: LanguageTag ) encoder: [ :languageTag | languageTag asString ].
  neoJSONWriter writeMapStreamingDo: [ :jsonMapWriter |
      jsonMapWriter
        writeKey: #code value: self code;
        writeKey: #message value: self messageText;
        writeKey: #allowedMediaTypes value: self allowedMediaTypes;
        writeKey: #allowedLanguageTags value: self allowedLanguageTags
    ]
]
