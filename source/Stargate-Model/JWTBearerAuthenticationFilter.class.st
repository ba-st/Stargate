"
I'm an authentication filter using Bearer tokens in JWT format
"
Class {
	#name : 'JWTBearerAuthenticationFilter',
	#superclass : 'AuthenticationFilter',
	#instVars : [
		'key',
		'algorithm',
		'realm'
	],
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'private' }
JWTBearerAuthenticationFilter class >> canHandle: configuration [

	| schema algorithm |
	schema := configuration at: #authSchema ifAbsent: [ ^ false ].
	algorithm := configuration at: #authAlgorithm ifAbsent: [ ^ false ].
	^ schema = 'jwt' and: [
		  algorithm ~= JWANone parameterValue and: [
			  JsonWebAlgorithm supportsAlgorithmNamed: algorithm ] ]
]

{ #category : 'private' }
JWTBearerAuthenticationFilter class >> configuredBy: configuration [

  ^ self
      with: ( configuration at: #authSecret ifAbsent: [ self signalMissingConfiguration ] )
      forAlgorithmNamed: ( configuration at: #authAlgorithm )
      on: ( configuration at: #authRealm )
]

{ #category : 'instance creation' }
JWTBearerAuthenticationFilter class >> with: aKey forAlgorithmNamed: anAlgorithmName on: aRealm [

  ^ self new
      initializeWith: aKey
      forAlgorithm: ( JsonWebAlgorithm named: anAlgorithmName )
      on: aRealm
]

{ #category : 'accessing' }
JWTBearerAuthenticationFilter >> authChallenge [

  ^ 'Bearer realm=<1s>' expandMacrosWith: realm asString
]

{ #category : 'private' }
JWTBearerAuthenticationFilter >> checkCredentials: authorization for: httpRequest within: requestContext [

  | tokenString |
  ( authorization beginsWith: 'Bearer ' ) ifFalse: [
      HTTPUnauthorized signal: 'Unsupported authentication scheme' with: self authChallenge ].
  tokenString := authorization allButFirst: 7.
  [
    | jws |
    jws := JsonWebSignature materializeCompact: tokenString key: key.
    jws algorithm = algorithm ifFalse: [
        HTTPUnauthorized
          signal: 'Unsupported algorithm'
          becauseTokenIsInvalidWith: self authChallenge ].
    requestContext
      authChallenge: self authChallenge;
      permissions: jws payload permissions
  ]
    on: Error
    do: [ :error |
        error return:
          ( HTTPUnauthorized signal: 'Invalid token' becauseTokenIsInvalidWith: self authChallenge )
      ]
]

{ #category : 'initialization' }
JWTBearerAuthenticationFilter >> initializeWith: aKey forAlgorithm: anAlgorithm on: aRealm [

	key := aKey .
	algorithm := anAlgorithm.
	realm := aRealm
]
