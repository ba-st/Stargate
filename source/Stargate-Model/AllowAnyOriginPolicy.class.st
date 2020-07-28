"
I'm a policy configuring a CORS filter in such a way that sets Access-Control-Allow-Origin header to allow any origin.
"
Class {
	#name : #AllowAnyOriginPolicy,
	#superclass : #AllowOriginPolicy,
	#category : #'Stargate-Model-CORS'
}

{ #category : #'configuring headers' }
AllowAnyOriginPolicy >> accessControlAllowOrigin [

	^ Headers >> #accessControlAllowOrigin
]

{ #category : #'configuring headers' }
AllowAnyOriginPolicy >> applyOn: aFilter for: aRequest [

	aFilter set: '*' toHeaderNamed: self accessControlAllowOrigin
]
