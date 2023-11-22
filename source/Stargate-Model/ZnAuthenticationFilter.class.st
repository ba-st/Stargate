"
I'm an authentication filter supporting the already provided ZnAuthenticators: ZnBasicAuthenticator or ZnDigestAuthenticator
"
Class {
	#name : 'ZnAuthenticationFilter',
	#superclass : 'AuthenticationFilter',
	#instVars : [
		'authenticator'
	],
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'private' }
ZnAuthenticationFilter class >> canHandle: configuration [

	| schema |

	schema := configuration at: #authSchema ifAbsent: [ ^ false ].
	^ schema = 'basic'
]

{ #category : 'private' }
ZnAuthenticationFilter class >> configuredBy: configuration [

	^ self
		username: ( configuration at: #authUsername ifAbsent: [ AssertionFailed signal: 'Missing username' ] )
		password: ( configuration at: #authPassword ifAbsent: [ AssertionFailed signal: 'Missing password' ] )
]

{ #category : 'instance creation' }
ZnAuthenticationFilter class >> username: username password: password [

	^ self using: ( ZnBasicAuthenticator username: username password: password )
]

{ #category : 'instance creation' }
ZnAuthenticationFilter class >> using: aZnAuthenticator [

	^ self new initializeUsing: aZnAuthenticator
]

{ #category : 'accessing' }
ZnAuthenticationFilter >> authChallenge [

	^ authenticator authHeader
]

{ #category : 'private' }
ZnAuthenticationFilter >> checkCredentials: authorization for: httpRequest within: requestContext ifInvalid: aBlock [

	( authenticator isRequestAuthenticated: httpRequest )
		ifFalse: aBlock
]

{ #category : 'initialization' }
ZnAuthenticationFilter >> initializeUsing: anAuthenticator [

	authenticator := anAuthenticator 
]
