"
I'm a policy configuring a CORS filter in such a way that sets Access-Control-Allow-Origin header to a specified set of origins. 
"
Class {
	#name : 'AllowSpecifiedOriginsPolicy',
	#superclass : 'AllowOriginPolicy',
	#instVars : [
		'allowedOrigins'
	],
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'instance creation' }
AllowSpecifiedOriginsPolicy class >> onlyFrom: anUrlCollection [

	^ self new initializeOnlyFrom: ( anUrlCollection collect: #asWebOrigin )
]

{ #category : 'configuring headers' }
AllowSpecifiedOriginsPolicy >> applyOn: aResponse for: aRequest using: aHandler [

	| requestOrigin |

	requestOrigin := ( aRequest headers at: aHandler headerNames >> #origin ) asWebOrigin.

	allowedOrigins
		detect: [ :origin | origin = requestOrigin ]
		ifFound: [ :allowedOrigin |
			aHandler set: allowedOrigin asAllowOriginOn: aResponse.
			allowedOrigins size > 1 ifTrue: [ aResponse addToVary: aHandler headerNames >> #origin ]
			]
		ifNone: [ aRequest abort: TeaResponse noContent ]
]

{ #category : 'initialization' }
AllowSpecifiedOriginsPolicy >> initializeOnlyFrom: origins [

	allowedOrigins := origins
]
