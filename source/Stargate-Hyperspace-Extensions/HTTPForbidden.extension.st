Extension { #name : 'HTTPForbidden' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> affectResponse: response [

  response setWWWAuthenticate:
    ( self hasErrorCode
        then: [ self challengeDescribingError asString ]
        otherwise: [ self challenge ] )
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> challengeDescribingError [

  | describedChallenge |
  describedChallenge := AuthenticationChallenge
                          extending: self challenge
                          withError: self errorCode
                          describedAs: self messageText.
  self withRequiredPermissionsDo: [ :permissions |
      describedChallenge
        addParameterNamed: 'scope'
        quotingIfRepresentable: ( Character space asString join: permissions )
    ].
  ^ describedChallenge
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> hasErrorCode [

  ^ self errorCode notNil
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> neoJsonOn: neoJSONWriter [

  neoJSONWriter writeMapStreamingDo: [ :jsonMapWriter |
      jsonMapWriter
        writeKey: #code value: self code;
        writeKey: #message value: self messageText;
        writeKey: #errorCode value: self errorCode.
      self withRequiredPermissionsDo: [ :permissions |
          jsonMapWriter writeKey: #scope value: ( Character space asString join: permissions ) ]
    ]
]
