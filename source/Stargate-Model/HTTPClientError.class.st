"
I'm an exception expecting to be raised when someone makes an incorrect HTTP request.
"
Class {
	#name : #HTTPClientError,
	#superclass : #Error,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'*Stargate-Model' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

	neoJSONWriter
		writeMap:
			{(#code -> self code).
			(#message -> self messageText)} asDictionary
]
