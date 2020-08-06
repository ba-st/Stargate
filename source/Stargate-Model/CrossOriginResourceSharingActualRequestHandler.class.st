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
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingActualRequestHandler class >> allowing: anAllowOriginPolicy applying: addHeaderCommands [ 
	
	^ self new initializeAllowing: anAllowOriginPolicy applying: addHeaderCommands 
]

{ #category : #initialization }
CrossOriginResourceSharingActualRequestHandler >> initializeAllowing: anAllowOriginPolicy applying: aCommandCollection [

	allowOriginPolicy := anAllowOriginPolicy.
	optionalHeaderCommands := aCommandCollection.
]

{ #category : #'private - evaluating' }
CrossOriginResourceSharingActualRequestHandler >> setAllowedOriginOn: aResponse from: aRequest [ 

	allowOriginPolicy applyOn: aResponse for: aRequest using: self
]

{ #category : #'private - evaluating' }
CrossOriginResourceSharingActualRequestHandler >> setOptionalHeadersOn: aResponse [

	optionalHeaderCommands do: [ :command | command value: aResponse headers value: self headerNames ]
]

{ #category : #evaluating }
CrossOriginResourceSharingActualRequestHandler >> teaEvalActionOnRequest: aRequest response: aResponse [

	self setAllowedOriginOn: aResponse from: aRequest.
	self setOptionalHeadersOn: aResponse.
	
	^ aResponse
]
