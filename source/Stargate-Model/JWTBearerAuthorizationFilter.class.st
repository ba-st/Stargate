"
I'm an authorization filter using Bearer tokens in JWT format.
I'm skipping signature verification of the token on purpose,
under the assumption that it's already made outside the image.
So I just materalize the token and extract the permissions
making them available in the request context for further processing
on the controllers.
"
Class {
	#name : 'JWTBearerAuthorizationFilter',
	#superclass : 'SecurityFilter',
	#instVars : [
		'realm'
	],
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'instance creation' }
JWTBearerAuthorizationFilter class >> on: aRealm [

  ^ self new initializeOn: aRealm
]

{ #category : 'accessing' }
JWTBearerAuthorizationFilter >> authChallenge [

  ^ 'Bearer realm=<1s>' expandMacrosWith: realm asString
]

{ #category : 'private' }
JWTBearerAuthorizationFilter >> checkCredentials: authorization for: httpRequest within: requestContext [

  | tokenString |
  ( authorization beginsWith: 'Bearer ' ) ifFalse: [
      HTTPForbidden signal: 'Unsupported authorization scheme' with: self authChallenge ].
  tokenString := authorization allButFirst: 7.
  [
    | jws |
    jws := JsonWebSignature materializeCompact: tokenString key: '' checkSignature: false.
    requestContext
      authChallenge: self authChallenge;
      permissions: jws payload permissions
  ]
    on: Error
    do: [ :error | error return: ( HTTPForbidden signal: 'Invalid token' with: self authChallenge ) ]
]

{ #category : 'initialization' }
JWTBearerAuthorizationFilter >> initializeOn: aRealm [

	realm := aRealm
]

{ #category : 'private' }
JWTBearerAuthorizationFilter >> signalMissingAuthorizationHeader [

  ^ HTTPForbidden signal: 'Forbidden' with: self authChallenge
]
