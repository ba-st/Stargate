"
A RESTfulRequestExceptionHandlerTest is a test class for testing the behavior of RESTfulRequestExceptionHandler
"
Class {
	#name : #RESTfulRequestExceptionHandlerTest,
	#superclass : #TestCase,
	#instVars : [
		'exceptionHandler'
	],
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #running }
RESTfulRequestExceptionHandlerTest >> setUp [

	super setUp.
	exceptionHandler := RESTfulRequestExceptionHandler new
]

{ #category : #tests }
RESTfulRequestExceptionHandlerTest >> testHandlingConflict [

	self
		should: [ exceptionHandler handleConflictsDuring: [ ConflictingObjectFound signal ] ]
		raise: HTTPClientError conflict.

	self shouldnt: [ exceptionHandler handleConflictsDuring: [  ] ] raise: HTTPClientError.

	exceptionHandler addAsConflictError: ZeroDivide.

	self
		should: [ exceptionHandler handleConflictsDuring: [ ConflictingObjectFound signal ] ]
			raise: HTTPClientError conflict;
		should: [ exceptionHandler handleConflictsDuring: [ 1 / 0 ] ] raise: HTTPClientError conflict
]

{ #category : #tests }
RESTfulRequestExceptionHandlerTest >> testHandlingDecodingFailed [

	self
		should: [ exceptionHandler handleDecodingFailedDuring: [ TeaNoSuchParam signal ] ]
			raise: HTTPClientError badRequest;
		should: [ exceptionHandler handleDecodingFailedDuring: [ NeoJSONParseError signal ] ]
			raise: HTTPClientError badRequest.

	self shouldnt: [ exceptionHandler handleDecodingFailedDuring: [  ] ] raise: HTTPClientError.

	exceptionHandler addAsDecodingError: ZeroDivide.

	self
		should: [ exceptionHandler handleDecodingFailedDuring: [ TeaNoSuchParam signal ] ]
			raise: HTTPClientError badRequest;
		should: [ exceptionHandler handleDecodingFailedDuring: [ NeoJSONParseError signal ] ]
			raise: HTTPClientError badRequest;
		should: [ exceptionHandler handleDecodingFailedDuring: [ 1 / 0 ] ]
			raise: HTTPClientError badRequest
]

{ #category : #tests }
RESTfulRequestExceptionHandlerTest >> testHandlingDecodingFailedWhenEntityIsUnprocessable [

	self
		should: [ exceptionHandler handleDecodingFailedDuring: [ InstanceCreationFailed signal ] ]
		raise: HTTPClientError unprocessableEntity.

	exceptionHandler addAsUnprocessableEntityError: ZeroDivide.

	self
		should: [ exceptionHandler handleDecodingFailedDuring: [ 1 / 0 ] ]
		raise: HTTPClientError unprocessableEntity
]

{ #category : #tests }
RESTfulRequestExceptionHandlerTest >> testHandlingMissingQueryParameters [

	self
		should: [ exceptionHandler handleMissingQueryParametersDuring: [ TeaNoSuchParam signal ] ]
		raise: HTTPClientError badRequest.

	self shouldnt: [ exceptionHandler handleMissingQueryParametersDuring: [  ] ] raise: HTTPClientError.

	exceptionHandler addAsMissingQueryParameterError: ZeroDivide.

	self
		should: [ exceptionHandler handleMissingQueryParametersDuring: [ TeaNoSuchParam signal ] ]
			raise: HTTPClientError badRequest;
		should: [ exceptionHandler handleMissingQueryParametersDuring: [ 1 / 0 ] ]
			raise: HTTPClientError badRequest
]

{ #category : #tests }
RESTfulRequestExceptionHandlerTest >> testHandlingNotFound [

	self
		should: [ exceptionHandler handleNotFoundDuring: [ ObjectNotFound signal ] ]
		raise: HTTPClientError notFound.

	self shouldnt: [ exceptionHandler handleNotFoundDuring: [  ] ] raise: HTTPClientError.

	exceptionHandler addAsNotFoundError: ZeroDivide.

	self
		should: [ exceptionHandler handleNotFoundDuring: [ ObjectNotFound signal ] ]
			raise: HTTPClientError notFound;
		should: [ exceptionHandler handleNotFoundDuring: [ 1 / 0 ] ] raise: HTTPClientError notFound
]
