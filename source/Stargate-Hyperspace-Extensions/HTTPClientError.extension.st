Extension { #name : #HTTPClientError }

{ #category : #'*Stargate-Hyperspace-Extensions' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

	neoJSONWriter
		writeMap:
			( Dictionary new
				at: #code put: self code;
				at: #message put: self messageText;
				yourself )
]
