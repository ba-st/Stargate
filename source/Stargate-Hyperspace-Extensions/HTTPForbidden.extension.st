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
  self withScopeDo: [ :scope |
      describedChallenge addParameterNamed: 'scope' quotingIfRepresentable: scope ].
  ^ describedChallenge
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> hasErrorCode [

  ^ self errorCode notNil
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> withScopeDo: aBlock [
  "The scope is the space-delimited list of the required permissions"

  self withRequiredPermissionsDo: [ :permissions |
      aBlock value: ( Character space asString join: permissions ) ]
]

{ #category : '*Stargate-Hyperspace-Extensions' }
HTTPForbidden >> writeAdditionalDataOn: jsonMapWriter [
  "The required permissions are written as the scope, the space-delimited list used in the challenge"

  self additionalDataKeysAndValuesDo: [ :key :value |
      key = 'requiredPermissions'
        ifTrue: [ jsonMapWriter writeKey: #scope value: ( Character space asString join: value ) ]
        ifFalse: [ jsonMapWriter writeKey: key value: value ]
    ]
]
