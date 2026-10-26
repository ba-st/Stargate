Extension { #name : 'HTTPClientError' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPClientError >> affectResponse: response [

  
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

  ( neoJSONWriter customMappingFor: ZnMimeType ) encoder: [ :mediaType | mediaType asString ].
  ( neoJSONWriter customMappingFor: LanguageTag ) encoder: [ :languageTag | languageTag asString ].
  neoJSONWriter writeMapStreamingDo: [ :jsonMapWriter |
      jsonMapWriter
        writeKey: #code value: self code;
        writeKey: #message value: self messageText.
      self writeAdditionalDataOn: jsonMapWriter
    ]
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPClientError >> writeAdditionalDataOn: jsonMapWriter [

  self additionalDataKeysAndValuesDo: [ :key :value | jsonMapWriter writeKey: key value: value ]
]
