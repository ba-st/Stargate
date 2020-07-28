"
I'm a after filter handler for the actual request. I add CORS specific headers to the response. 
"
Class {
	#name : #CrossOriginResourceSharingActualRequestHandler,
	#superclass : #CrossOriginResourceSharingHandler,
	#instVars : [
		'allowOriginPolicy',
		'optionalHeaderCommands'
	],
	#pools : [
		'CrossOriginResourceSharing'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingActualRequestHandler class >> allowing: anAllowOriginPolicy applying: addHeaderCommands [ 
	
	^ self new initializeAllowing: anAllowOriginPolicy applying: addHeaderCommands 
]

{ #category : #'header names' }
CrossOriginResourceSharingActualRequestHandler >> accessControlAllowCredentials [

	^ Headers >> #accessControlAllowCredentials
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingActualRequestHandler >> collectAllowedOriginFrom: aRequest [

	allowOriginPolicy applyOn: self for: aRequest
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingActualRequestHandler >> collectOptionalHeaders [

	optionalHeaderCommands do: [ :command | command value: self ]
]

{ #category : #initialization }
CrossOriginResourceSharingActualRequestHandler >> initializeAllowing: anAllowOriginPolicy applying: aCommandCollection [

	allowOriginPolicy := anAllowOriginPolicy.
	optionalHeaderCommands := aCommandCollection.
	
	headers := Dictionary new
]

{ #category : #'header names' }
CrossOriginResourceSharingActualRequestHandler >> origin [

	^ Headers >> #origin
]

{ #category : #evaluating }
CrossOriginResourceSharingActualRequestHandler >> teaEvalActionOnRequest: aRequest response: aResponse [

	self collectAllowedOriginFrom: aRequest.
	self collectOptionalHeaders.
	self applyHeadersTo: aResponse.
	
	^ aResponse
]
