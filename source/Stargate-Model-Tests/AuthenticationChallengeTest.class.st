"
An AuthenticationChallengeTest is a test class for testing the behavior of AuthenticationChallenge
"
Class {
	#name : 'AuthenticationChallengeTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Auth',
	#package : 'Stargate-Model-Tests',
	#tag : 'Auth'
}

{ #category : 'tests' }
AuthenticationChallengeTest >> testExtendingChallengeWithoutParameters [

  | challenge |
  challenge := AuthenticationChallenge extending: 'Bearer'.
  challenge addParameterNamed: 'error' quoting: 'invalid_token'.

  self assert: challenge asString equals: 'Bearer error="invalid_token"'
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testExtendingKeepsChallenge [

  self
    assert: ( AuthenticationChallenge extending: 'Bearer realm="api.example.com"' ) asString
    equals: 'Bearer realm="api.example.com"'
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testExtendingWithError [

  | challenge |
  challenge := AuthenticationChallenge
                 extending: 'Bearer realm="api.example.com"'
                 withError: 'invalid_token'
                 describedAs: 'Invalid token'.

  self
    assert: challenge asString
    equals:
    'Bearer realm="api.example.com", error="invalid_token", error_description="Invalid token"'
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testExtendingWithErrorDescribedWithUnrepresentableCharacters [

  { 'Invalid "token"' . 'Invalid \ token' . 'Token inválido' . 'Invalid'
    , ( String with: Character tab ) , 'token' } do: [ :description |
      self
        assert: ( AuthenticationChallenge
              extending: 'Bearer realm="api.example.com"'
              withError: 'invalid_token'
              describedAs: description ) asString
        equals: 'Bearer realm="api.example.com", error="invalid_token"'
    ]
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testExtendingWithRepresentableScope [

  | challenge |
  challenge := AuthenticationChallenge extending: 'Bearer realm="api.example.com"'.
  challenge addParameterNamed: 'scope' quotingIfRepresentable: 'read:pets update:pets'.

  self
    assert: challenge asString
    equals: 'Bearer realm="api.example.com", scope="read:pets update:pets"'
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testSchemeAndRealm [

  self
    assert: ( AuthenticationChallenge scheme: 'Bearer' realm: 'api.example.com' ) asString
    equals: 'Bearer realm="api.example.com"'
]

{ #category : 'tests' }
AuthenticationChallengeTest >> testSchemeAndRealmNeedingEscapes [

  self
    assert: ( AuthenticationChallenge scheme: 'Bearer' realm: 'The "Pets" \ API' ) asString
    equals: 'Bearer realm="The \"Pets\" \\ API"'
]
