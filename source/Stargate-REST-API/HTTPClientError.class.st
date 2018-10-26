"
I'm an exception expecting to be raised when someone makes an incorrect HTTP request.
"
Class {
	#name : #HTTPClientError,
	#superclass : #Error,
	#category : #'Stargate-REST-API-Services'
}

{ #category : #signaling }
HTTPClientError class >> signal: aCode describedBy: aFailureExplanation [

	^ self new
		tag: aCode;
		signal: aFailureExplanation
]

{ #category : #signaling }
HTTPClientError class >> signalBadRequest: aFailureExplanation [

	^ self signal: 400 describedBy: aFailureExplanation
]

{ #category : #signaling }
HTTPClientError class >> signalConflict: aFailureExplanation [

	^self signal: 409 describedBy: aFailureExplanation
]

{ #category : #signaling }
HTTPClientError class >> signalNotFound [

	^self signal: 404 describedBy: 'Not found'
]

{ #category : #signaling }
HTTPClientError class >> signalNotFound: aFailureExplanation [

	^self signal: 404 describedBy: aFailureExplanation 
]

{ #category : #signaling }
HTTPClientError class >> signalUnsupportedMediaType: aFailureExplanation [

	^ self signal: 415 describedBy: aFailureExplanation
]

{ #category : #accessing }
HTTPClientError >> code [

	^self tag
]
