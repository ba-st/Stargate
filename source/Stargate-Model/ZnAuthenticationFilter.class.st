"
I'm an authentication filter supporting the already provided ZnAuthenticators: ZnBasicAuthenticator or ZnDigestAuthenticator
"
Class {
	#name : #ZnAuthenticationFilter,
	#superclass : #AuthenticationFilter,
	#instVars : [
		'authenticator'
	],
	#category : #'Stargate-Model-Auth'
}

{ #category : #'instance creation' }
ZnAuthenticationFilter class >> username: username password: password [

	^ self using: ( ZnBasicAuthenticator username: username password: password )
]

{ #category : #'instance creation' }
ZnAuthenticationFilter class >> using: aZnAuthenticator [

	^ self new initializeUsing: aZnAuthenticator
]

{ #category : #accessing }
ZnAuthenticationFilter >> authChallenge [

	^ authenticator authHeader
]

{ #category : #private }
ZnAuthenticationFilter >> checkCredentials: authorization for: httpRequest ifInvalid: aBlock [

	( authenticator isRequestAuthenticated: httpRequest )
		ifFalse: aBlock
]

{ #category : #initialization }
ZnAuthenticationFilter >> initializeUsing: anAuthenticator [

	authenticator := anAuthenticator 
]
