"
A HTTPClientErrorTest is a test class for testing the behavior of HTTPClientError
"
Class {
	#name : #HTTPClientErrorTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests-Model'
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
HTTPClientErrorTest >> testCode [

	self
		should: [ HTTPClientError signal: 404 describedBy: 'Not Found' ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | 
			self
				assert: signal code equals: 404;
				assert: signal messageText equals: 'Not Found' ]
]
