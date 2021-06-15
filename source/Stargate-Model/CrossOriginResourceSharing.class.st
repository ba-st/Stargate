"
I'm a shared pool providing the CORS constants
"
Class {
	#name : #CrossOriginResourceSharing,
	#superclass : #SharedPool,
	#classVars : [
		'Headers'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #accessing }
CrossOriginResourceSharing class >> headers [ 
	
	<ignoreForCoverage>
	^ Headers
]

{ #category : #'class initialization' }
CrossOriginResourceSharing class >> inializeHeaders [

	<ignoreForCoverage>
	Headers := Namespace new.
	Headers
		bind: #origin to: 'Origin';
		bind: #accessControlRequestHeaders to: 'Access-Control-Request-Headers';
		bind: #accessControlRequestMethod to: 'Access-Control-Request-Method';
		bind: #accessControlAllowOrigin to: 'Access-Control-Allow-Origin';
		bind: #accessControlAllowMethods to: 'Access-Control-Allow-Methods';
		bind: #accessControlAllowHeaders to: 'Access-Control-Allow-Headers';
		bind: #accessControlAllowCredentials to: 'Access-Control-Allow-Credentials';
		bind: #accessControlMaxAge to: 'Access-Control-Max-Age';
		bind: #accessControlExposeHeaders to: 'Access-Control-Expose-Headers'
]

{ #category : #'class initialization' }
CrossOriginResourceSharing class >> initialize [

	<ignoreForCoverage>
	self inializeHeaders
]
