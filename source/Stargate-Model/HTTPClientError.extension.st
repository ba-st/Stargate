Extension { #name : #HTTPClientError }

{ #category : #'*Stargate-Model' }
HTTPClientError >> neoJsonOn: neoJSONWriter [

	neoJSONWriter
		writeMap:
			( Dictionary new
				at: #code put: self code;
				at: #message put: self messageText;
				yourself )
]
