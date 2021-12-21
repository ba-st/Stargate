"
A JsonRPCControllerTest is a test class for testing the behavior of JsonRPCController
"
Class {
	#name : #JsonRPCControllerTest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#instVars : [
		'errors',
		'controller'
	],
	#category : #'Stargate-JSON-RPC-Tests'
}

{ #category : #private }
JsonRPCControllerTest >> basicArithmeticDefinitions [

	^ [ :requestHandler | 
	  requestHandler
		  addHandlerNamed: 'add' evaluating: [ :first :second | first + second ];
		  addHandlerNamed: 'div' evaluating: [ :dividend :divisor | dividend / divisor ];
		  addHandlerNamed: 'mul' evaluating: [ :dividend :divisor | dividend * divisor ];
		  addHandlerNamed: 'sub'
		  withArgumentNames: #( minuend subtrahend )
		  evaluating: [ :first :second | first - second ]
	  ]
]

{ #category : #private }
JsonRPCControllerTest >> controllersToInstall [

	^ { controller }
]

{ #category : #running }
JsonRPCControllerTest >> setUpAPI [

	errors := OrderedCollection new.
	controller := JsonRPCController configuredBy: [ :options | 
		              options
			              at: #endpoint put: #calc;
			              at: #procedureDefinitions put: { self basicArithmeticDefinitions };
			              at: #errorHandlers put: { [ :error | errors add: error ] }
		              ].
	super setUpAPI
]

{ #category : #tests }
JsonRPCControllerTest >> testRunAdditionProcedure [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity: ( ZnEntity json: '{"jsonrpc":"2.0","id":1,"method":"add","params":[1,2]}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: json result equals: 3
			].

	self assert: errors isEmpty
]

{ #category : #tests }
JsonRPCControllerTest >> testRunDivisionProcedure [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity: ( ZnEntity json: '{"jsonrpc":"2.0","id":1,"method":"div","params":[4,2]}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: json result equals: 2
			].

	self assert: errors isEmpty
]

{ #category : #tests }
JsonRPCControllerTest >> testRunDivisionProcedureWhenFails [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity: ( ZnEntity json: '{"jsonrpc":"2.0","id":1,"method":"div","params":[1,0]}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'Internal JSON-RPC error.';
				assert: ( json at: #error ) code equals: -32603
			].

	self assert: errors size equals: 1
]

{ #category : #tests }
JsonRPCControllerTest >> testRunSubtractionProcedure [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity:
			            ( ZnEntity json:
					              '{"jsonrpc":"2.0","id":1,"method":"sub","params":{"subtrahend":1,"minuend":2}}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: json result equals: 1
			].

	self assert: errors isEmpty
]

{ #category : #tests }
JsonRPCControllerTest >> testRunSubtractionProcedureMissingParameter [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity:
			            ( ZnEntity json:
					              '{"jsonrpc":"2.0","id":1,"method":"sub","params":{"subtrahend":1,"second":2}}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'Invalid method parameter(s).'
			].

	self assert: errors size equals: 1
]

{ #category : #tests }
JsonRPCControllerTest >> testRunSubtractionProcedureUsingArray [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity: ( ZnEntity json: '{"jsonrpc":"2.0","id":1,"method":"sub","params":[4,1]}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: json result equals: 3
			].

	self assert: errors isEmpty
]

{ #category : #tests }
JsonRPCControllerTest >> testRunSubtractionProcedureWithMoreParameters [

	| response |

	response := self newClient
		            url: self baseUrl / 'calc';
		            entity: ( ZnEntity json: '{"jsonrpc":"2.0","id":1,"method":"sub","params":[1,2,3]}' );
		            post;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'Invalid method parameter(s).'
			].

	self assert: errors size equals: 1
]
