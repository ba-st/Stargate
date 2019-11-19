"
An ApplicationControlRESTfulControllerTest is a test class for testing the behavior of ApplicationControlRESTfulController
"
Class {
	#name : #ApplicationControlRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#category : #'Stargate-Application-Control-Tests'
}

{ #category : #'private - support' }
ApplicationControlRESTfulControllerTest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationControlPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #commands put: #('shutdown');
				yourself );
		yourself
]

{ #category : #running }
ApplicationControlRESTfulControllerTest >> setUpResourceController [

	resourceController := ApplicationControlRESTfulController
		over: ( ApplicationControlPlugin configuredBy: self operationsConfiguration )
		configuredBy: self operationsConfiguration
]

{ #category : #tests }
ApplicationControlRESTfulControllerTest >> testRunShutdownCommandAsCall [

	| response |

	response := [ resourceController
		runApplicationControlMethodBasedOn:
			( ( ZnRequest post: self resourceUrl )
				entity:
					( ZnEntity
						json:
							'{
	"jsonrpc" : "2.0",
	"id" : 1,
	"method" : "shutdown"
}' );
				yourself )
		within: self newHttpRequestContext
	]
		on: Exit
		do: [ :exit | exit resume: exit messageText ].

	self
		assert: response isSuccess;
		assert: response code equals: 200;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json jsonrpc equals: '2.0';
				assert: json id equals: 1;
				assert: json result equals: 'Remote SHUTDOWN command was received.'
			]
]

{ #category : #tests }
ApplicationControlRESTfulControllerTest >> testRunShutdownCommandAsNotification [

	| response |

	response := [ resourceController
		runApplicationControlMethodBasedOn:
			( ( ZnRequest post: self resourceUrl )
				entity:
					( ZnEntity
						json:
							'{
	"jsonrpc" : "2.0",
	"method" : "shutdown"
}' );
				yourself )
		within: self newHttpRequestContext
	]
		on: Exit
		do: [ :exit | exit resume ].

	self
		assert: response isSuccess;
		assert: response code equals: 202;
		deny: response hasEntity
]

{ #category : #tests }
ApplicationControlRESTfulControllerTest >> testRunUnknownCommand [

	| response |

	response := resourceController
		runApplicationControlMethodBasedOn:
			( ( ZnRequest post: self resourceUrl )
				entity:
					( ZnEntity
						json:
							'{
	"jsonrpc" : "2.0",
	"id" : 1,
	"method" : "xxx"
}' );
				yourself )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response code equals: 200;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json jsonrpc equals: '2.0';
				assert: json id equals: 1;
				assert: ( json at: #error ) code equals: -32601;
				assert: ( json at: #error ) message equals: 'The method does not exist / is not available.'
			]
]
