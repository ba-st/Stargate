"
A HTTPClientErrorTest is a test class for testing the behavior of HTTPClientError
"
Class {
	#name : #HTTPClientErrorTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #tests }
HTTPClientErrorTest >> test404 [

	self
		should: [ HTTPClientError signalNotFound ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | 
			self
				assert: signal code equals: 404;
				assert: signal messageText equals: 'Not found' ]
]

{ #category : #tests }
HTTPClientErrorTest >> test409 [

	self
		should: [ HTTPClientError signalConflict: 'Sigmund Freud' ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | 
			self
				assert: signal code equals: 409;
				assert: signal messageText equals: 'Sigmund Freud' ]
]

{ #category : #tests }
HTTPClientErrorTest >> test422 [

	self
		should: [ HTTPClientError signalUnprocessableEntity: 'Cannot be processed']
		raise: HTTPClientError
		withExceptionDo: [ :signal | 
			self
				assert: signal code equals: 422;
				assert: signal messageText equals: 'Cannot be processed' ]
]

{ #category : #tests }
HTTPClientErrorTest >> testCode [

	self
		should: [ HTTPClientError signal: 404 describedBy: 'Not Found' ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | 
			self
				assert: signal code equals: 404;
				assert: signal messageText equals: 'Not Found' ]
]

{ #category : #tests }
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
