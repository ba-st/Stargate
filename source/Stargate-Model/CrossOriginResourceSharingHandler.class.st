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
CrossOriginResourceSharingHandler >> set: anOrigin asAllowOriginOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: anOrigin asString
]

{ #category : #'private - evaluating' }
CrossOriginResourceSharingHandler >> setAnyOriginAllowedOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: '*'
]
