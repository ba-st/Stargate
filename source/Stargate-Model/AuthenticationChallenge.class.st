"
I represent a challenge of the WWW-Authenticate header: an authentication scheme followed by a comma-separated list of auth-params, each value written as a quoted string.

I can start from a challenge already written as a string, such as the one an HTTP error carries, and extend it with more auth-params.

References:
- [RFC 7235](https://datatracker.ietf.org/doc/html/rfc7235#section-2.1)
- [RFC 6750](https://datatracker.ietf.org/doc/html/rfc6750#section-3)
"
Class {
	#name : 'AuthenticationChallenge',
	#superclass : 'Object',
	#instVars : [
		'challenge',
		'parameters'
	],
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'instance creation' }
AuthenticationChallenge class >> extending: aChallenge [

  ^ self new initializeExtending: aChallenge
]

{ #category : 'instance creation' }
AuthenticationChallenge class >> extending: aChallenge withError: anErrorCode describedAs: aDescription [

  ^ ( self extending: aChallenge )
      addParameterNamed: 'error' quoting: anErrorCode;
      addParameterNamed: 'error_description' quotingIfRepresentable: aDescription;
      yourself
]

{ #category : 'instance creation' }
AuthenticationChallenge class >> scheme: aSchemeName realm: aRealm [

  ^ ( self extending: aSchemeName )
      addParameterNamed: 'realm' quoting: aRealm;
      yourself
]

{ #category : 'configuring' }
AuthenticationChallenge >> addParameterNamed: aName quoting: aValue [

  parameters add: aName -> aValue
]

{ #category : 'configuring' }
AuthenticationChallenge >> addParameterNamed: aName quotingIfRepresentable: aValue [
  "RFC 6750 restricts the error_description and scope values to printable US-ASCII characters
   other than the double quote and the backslash. Both attributes are optional, so a value
   outside that set is left out instead of being altered."

  ( self isRepresentable: aValue ) then: [ self addParameterNamed: aName quoting: aValue ]
]

{ #category : 'initialization' }
AuthenticationChallenge >> initializeExtending: aChallenge [

  challenge := aChallenge.
  parameters := OrderedCollection new
]

{ #category : 'private' }
AuthenticationChallenge >> isRepresentable: aValue [

  ^ aValue allSatisfy: [ :character |
        ( character asInteger between: 16r20 and: 16r7E ) and: [ ( '"\' includes: character ) not ] ]
]

{ #category : 'printing' }
AuthenticationChallenge >> printOn: aStream [

  | separator |
  aStream nextPutAll: challenge.
  separator := ( challenge includes: Character space ) then: [ ', ' ] otherwise: [ ' ' ].
  parameters do: [ :parameter |
      aStream
        nextPutAll: separator;
        nextPutAll: parameter key;
        nextPut: $=.
      self putQuoted: parameter value on: aStream.
      separator := ', '
    ]
]

{ #category : 'private' }
AuthenticationChallenge >> putQuoted: aString on: aStream [

  aStream nextPut: $".
  aString do: [ :character |
      ( '"\' includes: character ) then: [ aStream nextPut: $\ ].
      aStream nextPut: character
    ].
  aStream nextPut: $"
]
