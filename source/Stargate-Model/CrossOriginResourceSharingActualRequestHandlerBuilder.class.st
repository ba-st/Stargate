"
I'm a builder for CrossOriginResourceSharingActualRequestHandler instances.
"
Class {
	#name : #CrossOriginResourceSharingActualRequestHandlerBuilder,
	#superclass : #CrossOriginResourceSharingRequestHandlerBuilder,
	#instVars : [
		'allowOriginPolicyBinding',
		'addHeaderCommands'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #configuring }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowAnyOrigin [
	
	allowOriginPolicyBinding := Binding to: AllowAnyOriginPolicy new.
	
]

{ #category : #configuring }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowCredentials [

	addHeaderCommands
		add: [ :handler | handler set: true toHeaderNamed: 'Access-Control-Allow-Credentials' ]
]

{ #category : #configuring }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowOnlyFrom: origins [

	allowOriginPolicyBinding := Binding to: ( AllowSpecifiedOriginsPolicy onlyFrom: origins )
]

{ #category : #building }
CrossOriginResourceSharingActualRequestHandlerBuilder >> build [

	^ CrossOriginResourceSharingActualRequestHandler allowing: allowOriginPolicyBinding content applying: addHeaderCommands
]

{ #category : #configuring }
CrossOriginResourceSharingActualRequestHandlerBuilder >> expose: exposedHeaders [

	addHeaderCommands
		add: [ :filter | 
			exposedHeaders
				do: [ :exposedHeader | filter add: exposedHeader toHeaderNamed: 'Access-Control-Expose-Headers' ]
			]
]

{ #category : #initialization }
CrossOriginResourceSharingActualRequestHandlerBuilder >> initialize [

	allowOriginPolicyBinding := Binding undefinedExplainedBy: 'You must choose an allow origin policy'.
	addHeaderCommands := OrderedCollection new
]
