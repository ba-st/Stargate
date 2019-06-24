Extension { #name : #HTTPClientError }

{ #category : #'*Stargate-Model' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

	neoJSONWriter
		writeMap:
			{(#code -> self code).
			(#message -> self messageText)} asDictionary
]
