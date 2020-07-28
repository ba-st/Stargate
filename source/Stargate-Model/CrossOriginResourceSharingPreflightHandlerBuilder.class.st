"
I'm a builder for CrossOriginResourceSharingPreflightHandlerBuilder instances.
"
Class {
	#name : #CrossOriginResourceSharingPreflightHandlerBuilder,
	#superclass : #CrossOriginResourceSharingRequestHandlerBuilder,
	#instVars : [
		'allowedMethodsBinding',
		'allowOriginPolicyBinding',
		'addHeaderCommands'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> allowAnyOrigin [

	allowOriginPolicyBinding := Binding to: AllowAnyOriginPolicy new.
	
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> allowCredentials [

	addHeaderCommands
		add: [ :handler | handler set: true toHeaderNamed: 'Access-Control-Allow-Credentials' ]
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> allowMethods: methods [

	allowedMethodsBinding := Binding to: methods
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> allowOnlyFrom: origins [

	allowOriginPolicyBinding := Binding to: ( AllowSpecifiedOriginsPolicy onlyFrom: origins )
]

{ #category : #building }
CrossOriginResourceSharingPreflightHandlerBuilder >> build [

	^ CrossOriginResourceSharingPreflightHandler
		allowing: allowOriginPolicyBinding content
		accessTo: allowedMethodsBinding content
		applying: addHeaderCommands
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> doNotCache [

	addHeaderCommands add: [ :handler | handler set: -1 toHeaderNamed: 'Access-Control-Max-Age' ]
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> expireIn: aDuration [

	addHeaderCommands
		add: [ :filter | filter set: aDuration asSeconds toHeaderNamed: 'Access-Control-Max-Age' ]
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> expose: exposedHeaders [

	addHeaderCommands
		add: [ :filter | 
			exposedHeaders
				do: [ :exposedHeader | filter add: exposedHeader toHeaderNamed: 'Access-Control-Expose-Headers' ]
			]
]

{ #category : #initialization }
CrossOriginResourceSharingPreflightHandlerBuilder >> initialize [

	allowOriginPolicyBinding := Binding 
		undefinedExplainedBy: 'You must define an allow origin policy'.
	allowedMethodsBinding := Binding
		undefinedExplainedBy: 'You must provide allowed methos by endpoint'.
	addHeaderCommands := OrderedCollection new
]
