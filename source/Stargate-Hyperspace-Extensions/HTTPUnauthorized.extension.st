Extension { #name : 'HTTPUnauthorized' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> affectResponse: response [

  response setWWWAuthenticate: ( AuthenticationChallenge
        extending: self challenge
        withError: self errorCode
        describedAs: self messageText ) asString
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
