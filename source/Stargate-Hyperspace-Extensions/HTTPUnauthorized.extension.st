Extension { #name : 'HTTPUnauthorized' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> affectResponse: response [

  response setWWWAuthenticate: self challenge
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> neoJsonOn: neoJSONWriter [

  neoJSONWriter writeMapStreamingDo: [ :jsonMapWriter |
      jsonMapWriter
        writeKey: #code value: self code;
        writeKey: #message value: self messageText;
        writeKey: #errorCode value: self errorCode. 
    ]
]
