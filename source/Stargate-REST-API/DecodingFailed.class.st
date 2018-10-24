"
I'm an exception expecting to be raised when someone fails to decode or encode an object.
"
Class {
	#name : #DecodingFailed,
	#superclass : #Error,
	#category : #'Stargate-REST-API'
}

{ #category : #signalling }
DecodingFailed class >> signal: failureExplanation parsing: aString [

	^ self signalAll: (Array with: failureExplanation) parsing: aString
]

{ #category : #signalling }
DecodingFailed class >> signalAll: failureExplanations parsing: aString [

	^ (self new initializeParsing: aString explainedByAll: failureExplanations) signal: ('. ' join: failureExplanations)
]

{ #category : #initialization }
DecodingFailed >> failures [

	^ failures
]

{ #category : #initialization }
DecodingFailed >> initializeParsing: aString explainedByAll: failureExplanations [

	self tag: aString.
	failures := failureExplanations.
]
