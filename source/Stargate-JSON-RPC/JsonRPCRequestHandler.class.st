"
I represent a JSON RPC request handler. I'm capable of processing RPC calls.
"
Class {
	#name : #JsonRPCRequestHandler,
	#superclass : #Object,
	#instVars : [
		'messageProcessor',
		'acceptNegotiator',
		'resourceLocator'
	],
	#category : #'Stargate-JSON-RPC'
}

{ #category : #'instance creation' }
JsonRPCRequestHandler class >> handling: anEndpoint [

	^ self new initializeResolvingLocationWith: ( ResourceLocator handling: anEndpoint )
]

{ #category : #configuring }
JsonRPCRequestHandler >> addErrorHandler: anErrorHandler [

	messageProcessor addErrorHandler: anErrorHandler
]

{ #category : #configuring }
JsonRPCRequestHandler >> addHandlerNamed: aString evaluating: aBlock [

	messageProcessor addHandlerNamed: aString block: aBlock
]

{ #category : #configuring }
JsonRPCRequestHandler >> addHandlerNamed: aString withArgumentNames: argumentNames evaluating: aBlock [

	messageProcessor addHandlerNamed: aString withArgumentsNamed: argumentNames evaluating: aBlock
]

{ #category : #configuring }
JsonRPCRequestHandler >> debugMode: aBoolean [

	messageProcessor debugMode: aBoolean
]

{ #category : #accessing }
JsonRPCRequestHandler >> endpoint [

	^ resourceLocator endpoint
]

{ #category : #initialization }
JsonRPCRequestHandler >> initialize [

	super initialize.
	messageProcessor := JRPCMessageProcessor new.
	acceptNegotiator := RESTfulControllerAcceptNegotiator
		accepting: ( Array with: ZnMimeType applicationJson )
]

{ #category : #initialization }
JsonRPCRequestHandler >> initializeResolvingLocationWith: aResourceLocator [

	resourceLocator := aResourceLocator
]

{ #category : #API }
JsonRPCRequestHandler >> process: httpRequest within: requestContext [

	AssertionChecker
		enforce: [ httpRequest contentType = ZnMimeType applicationJson ]
		because: 'The request Content-Type must be application/json'
		raising: HTTPClientError unsupportedMediaType.
	acceptNegotiator bestRepresentationFor: httpRequest.

	^ ( messageProcessor handleJSON: httpRequest contents )
		ifEmpty: [ ZnResponse accepted ]
		ifNotEmpty: [ :rpcResponse | ZnResponse ok: ( ZnEntity json: rpcResponse ) ]
]

{ #category : #configuring }
JsonRPCRequestHandler >> serverUrl: aServerUrl [

	resourceLocator baseUrl: aServerUrl
]
