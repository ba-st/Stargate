"
I'm a builder for CrossOriginResourceSharingActualRequestHandler instances.
"
Class {
	#name : 'CrossOriginResourceSharingActualRequestHandlerBuilder',
	#superclass : 'CrossOriginResourceSharingRequestHandlerBuilder',
	#instVars : [
		'allowOriginPolicyBinding',
		'addHeaderCommands'
	],
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'configuring' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowAnyOrigin [
	
	allowOriginPolicyBinding := Binding to: AllowAnyOriginPolicy new.
	
]

{ #category : 'configuring' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowCredentials [

	addHeaderCommands
		add: [ :headers :headerNames | headers at: headerNames >> #accessControlAllowCredentials put: true asString ]
]

{ #category : 'configuring' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> allowOnlyFrom: origins [

	allowOriginPolicyBinding := Binding to: ( AllowSpecifiedOriginsPolicy onlyFrom: origins )
]

{ #category : 'building' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> build [

  ^ CrossOriginResourceSharingActualRequestHandler
      allowing: allowOriginPolicyBinding content
      applying: addHeaderCommands
]

{ #category : 'configuring' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> expose: exposedHeaders [

  addHeaderCommands add: [ :headers :headerNames |
      | headerName |
      headerName := headerNames >> #accessControlExposeHeaders.
      exposedHeaders do: [ :exposedHeader |
          [ headers at: headerName addSeparatedWithComma: exposedHeader ] unless:
            ( self is: exposedHeader alreadyIncludedAt: headerName in: headers )
        ]
    ]
]

{ #category : 'initialization' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> initialize [

	super initialize.
	allowOriginPolicyBinding := Binding undefinedExplainedBy: 'You must choose an allow origin policy'.
	addHeaderCommands := OrderedCollection new
]

{ #category : 'private' }
CrossOriginResourceSharingActualRequestHandlerBuilder >> is: exposedHeader alreadyIncludedAt: headerName in: headers [

  ^ ( ( ',' split: ( headers at: headerName ifAbsent: [ '' ] ) ) collect: [ :name | name trimBoth ] )
      includes: exposedHeader
]
