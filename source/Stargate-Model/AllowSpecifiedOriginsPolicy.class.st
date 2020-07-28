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

{ #category : #'accessing headers' }
AllowSpecifiedOriginsPolicy >> accessControlAllowOrigin [

	^ Headers >> #accessControlAllowOrigin
]

{ #category : #'configuring headers' }
AllowSpecifiedOriginsPolicy >> applyOn: aFilter for: aRequest [

	| requestOrigin |

	requestOrigin := ( aRequest headers at: self origin ) asUrl.

	allowedOrigins
		detect: [ :origin | origin = requestOrigin ]
		ifFound: [ :allowedOrigin | 
			aFilter set: allowedOrigin toHeaderNamed: self accessControlAllowOrigin.
			allowedOrigins size > 1
				ifTrue: [ aFilter add: self origin toHeaderNamed: self vary ]
			]
		ifNone: [ aRequest abort: TeaResponse noContent ]
]

{ #category : #initialization }
AllowSpecifiedOriginsPolicy >> initializeOnlyFrom: origins [

	allowedOrigins := origins 
]

{ #category : #'accessing headers' }
AllowSpecifiedOriginsPolicy >> origin [

	^ Headers >> #origin
]

{ #category : #'accessing headers' }
AllowSpecifiedOriginsPolicy >> vary [

	^ Headers >> #vary
]
