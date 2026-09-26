Extension { #name : 'HTTPForbidden' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> affectResponse: response [

  | challenge |
  challenge := AuthenticationChallenge
                 extending: self challenge
                 withError: self errorCode
                 describedAs: self messageText.
  self withRequiredPermissionsDo: [ :permissions |
      challenge
        addParameterNamed: 'scope'
        quotingIfRepresentable: ( Character space asString join: permissions )
    ].
  response setWWWAuthenticate: challenge asString
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
