Class {
	#name : #CrossOriginResourceSharingHandler,
	#superclass : #Object,
	#pools : [
		'CrossOriginResourceSharing'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'private - evaluating' }
CrossOriginResourceSharingHandler >> add: aHeaderNamed toVaryOn: aResponse [

	aResponse headers at: self headerNames >> #vary addSeparatedWithComma: aHeaderNamed
]

{ #category : #accessing }
CrossOriginResourceSharingHandler >> headerNames [

	^ Headers
]

{ #category : #'private - evaluating' }
CrossOriginResourceSharingHandler >> set: anyOrAnOrigin asAllowOriginOn: aResponse [
	
	aResponse headers at: self headerNames >> #accessControlAllowOrigin put: anyOrAnOrigin asString 
]
