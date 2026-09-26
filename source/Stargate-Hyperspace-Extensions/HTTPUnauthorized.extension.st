Extension { #name : 'HTTPUnauthorized' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> affectResponse: response [

  response setWWWAuthenticate:
    ( self hasErrorCode
        then: [ self challengeDescribingError asString ]
        otherwise: [ self challenge ] )
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> challengeDescribingError [

  ^ AuthenticationChallenge
      extending: self challenge
      withError: self errorCode
      describedAs: self messageText
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPUnauthorized >> hasErrorCode [

  ^ self errorCode notNil
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
