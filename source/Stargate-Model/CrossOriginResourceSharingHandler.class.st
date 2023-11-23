Class {
	#name : 'CrossOriginResourceSharingHandler',
	#superclass : 'Object',
	#classVars : [
		'Headers'
	],
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'class initialization' }
CrossOriginResourceSharingHandler class >> initialize [

	<ignoreForCoverage>
	Headers := Namespace new.
	Headers
		bind: #origin to: 'Origin';
		bind: #accessControlRequestHeaders
		to: 'Access-Control-Request-Headers';
		bind: #accessControlRequestMethod
		to: 'Access-Control-Request-Method';
		bind: #accessControlAllowOrigin to: 'Access-Control-Allow-Origin';
		bind: #accessControlAllowMethods to: 'Access-Control-Allow-Methods';
		bind: #accessControlAllowHeaders to: 'Access-Control-Allow-Headers';
		bind: #accessControlAllowCredentials
		to: 'Access-Control-Allow-Credentials';
		bind: #accessControlMaxAge to: 'Access-Control-Max-Age';
		bind: #accessControlExposeHeaders
		to: 'Access-Control-Expose-Headers'
]

{ #category : 'accessing' }
CrossOriginResourceSharingHandler >> headerNames [

	^ Headers
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingHandler >> set: anOrigin asAllowOriginOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: anOrigin asString
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingHandler >> setAnyOriginAllowedOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: '*'
]
