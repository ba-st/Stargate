"
I'm a policy configuring a CORS filter in such a way that sets Access-Control-Allow-Origin header to allow any origin.
"
Class {
	#name : 'AllowAnyOriginPolicy',
	#superclass : 'AllowOriginPolicy',
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'configuring headers' }
AllowAnyOriginPolicy >> applyOn: aResponse for: aRequest using: aHandler [

	aHandler setAnyOriginAllowedOn: aResponse
]
