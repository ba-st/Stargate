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
		add: [ :headers :headerNames | headers at: headerNames >> #accessControlAllowCredentials put: true asString ]
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

	addHeaderCommands
		add: [ :headers :headerNames | headers at: headerNames >> #accessControlMaxAge put: -1 asString ]
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> expireIn: aDuration [

	addHeaderCommands
		add:
			[ :headers :headerNames | headers at: headerNames >> #accessControlMaxAge put: aDuration asSeconds asString ]
]

{ #category : #configuring }
CrossOriginResourceSharingPreflightHandlerBuilder >> expose: exposedHeaders [

	addHeaderCommands
		add: [ :handler :headerNames | 
			exposedHeaders
				do:
					[ :exposedHeader | handler at: headerNames >> #accessControlExposeHeaders addSeparatedWithComma: exposedHeader ]
			]
]

{ #category : #initialization }
CrossOriginResourceSharingPreflightHandlerBuilder >> initialize [

	super initialize.
	allowOriginPolicyBinding := Binding 
		undefinedExplainedBy: 'You must define an allow origin policy'.
	allowedMethodsBinding := Binding
		undefinedExplainedBy: 'You must provide allowed methos by endpoint'.
	addHeaderCommands := OrderedCollection new
]
