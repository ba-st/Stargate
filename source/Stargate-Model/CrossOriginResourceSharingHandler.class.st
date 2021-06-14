Class {
	#name : #CrossOriginResourceSharingHandler,
	#superclass : #Object,
	#pools : [
		'CrossOriginResourceSharing'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #accessing }
CrossOriginResourceSharingHandler >> headerNames [

	^ Headers
]

{ #category : #'private - evaluating' }
CrossOriginResourceSharingHandler >> set: anyOrAnOrigin asAllowOriginOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: anyOrAnOrigin asString 
]
