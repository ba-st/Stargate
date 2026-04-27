Extension { #name : 'HTTPForbidden' }

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> affectResponse: response [

  response setWWWAuthenticate: self challenge
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
