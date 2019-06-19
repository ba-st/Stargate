Extension { #name : #HTTPClientErrorTest }

{ #category : #'*Stargate-Model-Tests' }
HTTPClientErrorTest >> testNotAcceptableAsJSON [

	| error json |

	error := HTTPNotAcceptable messageText: 'Ouch!' accepting: {'application/xml' asMediaType}.
	json := NeoJSONObject fromString: (NeoJSONWriter toStringPretty: error).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 406;
		assert: json allowedMediaTypes size equals: 1;
		assert: json allowedMediaTypes first equals: 'application/xml'
]
