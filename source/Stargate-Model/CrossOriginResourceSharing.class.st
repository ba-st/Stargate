"
I'm a shared pool with the CORS headers
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
	
	^ Headers
]

{ #category : #'class initialization' }
CrossOriginResourceSharing class >> inializeHeaders [

	Headers := Namespace new.
	Headers
		bind: #origin to: 'Origin';
		bind: #vary to: 'Vary';
		bind: #accessControlRequestHeaders to: 'Access-Control-Request-Headers';
		bind: #accessControlRequestMethod to:  'Access-Control-Request-Method';
		bind: #accessControlAllowOrigin to: 'Access-Control-Allow-Origin';
		bind: #accessControlAllowMethods to: 'Access-Control-Allow-Methods';
		bind: #accessControlAllowHeaders to: 'Access-Control-Allow-Headers';
		bind: #accessControlAllowCredentials to: 'Access-Control-Allow-Credentials'
]

{ #category : #'class initialization' }
CrossOriginResourceSharing class >> initialize [

	self inializeHeaders
]
