"
I'm a policy configuring a CORS filter in such a way that sets Access-Control-Allow-Origin header to a specified set of origins. 
"
Class {
	#name : #AllowSpecifiedOriginsPolicy,
	#superclass : #AllowOriginPolicy,
	#instVars : [
		'allowedOrigins'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
AllowSpecifiedOriginsPolicy class >> onlyFrom: origins [
	
	^ self new initializeOnlyFrom: origins
]

{ #category : #'configuring headers' }
AllowSpecifiedOriginsPolicy >> applyOn: aResponse for: aRequest using: aHandler [

	| requestOrigin |

	requestOrigin := ( aRequest headers at: aHandler headerNames >> #origin ) asUrl.

	allowedOrigins
		detect: [ :origin | origin = requestOrigin ]
		ifFound: [ :allowedOrigin | 
			aHandler set: ( self withoutLastSlash: allowedOrigin ) asAllowOriginOn: aResponse.
			allowedOrigins size > 1
				ifTrue: [ aResponse addToVary: aHandler headerNames >> #origin ]
			]
		ifNone: [ aRequest abort: TeaResponse noContent ]
]

{ #category : #initialization }
AllowSpecifiedOriginsPolicy >> initializeOnlyFrom: origins [

	allowedOrigins := origins collect: #asUrl
]

{ #category : #'configuring headers' }
AllowSpecifiedOriginsPolicy >> withoutLastSlash: allowedOrigin [

	^ allowedOrigin asString allButLast
]
