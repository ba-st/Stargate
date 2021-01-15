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
		add: [ :headers :headerNames | headers at: headerNames >> #accessControlAllowCredentials put: true asString ]
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
		add: [ :headers :headerNames | 
			exposedHeaders
				do:
					[ :exposedHeader | headers at: headerNames >> #accessControlExposeHeaders addSeparatedWithComma: exposedHeader ]
			]
]

{ #category : #initialization }
CrossOriginResourceSharingActualRequestHandlerBuilder >> initialize [

	super initialize.
	allowOriginPolicyBinding := Binding undefinedExplainedBy: 'You must choose an allow origin policy'.
	addHeaderCommands := OrderedCollection new
]
