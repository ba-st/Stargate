Extension { #name : 'HTTPClientError' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

  neoJSONWriter writeMapStreamingDo: [ :jsonMapWriter |
      jsonMapWriter
        writeKey: #code value: self code;
        writeKey: #message value: self messageText
    ]
]
