"
I represent a RESTful Controller.
I will provide some routes to be configured in a Teapot Server.
My subclasses must create one or more RESTfulRequestHandler (usually with the available builder), 
and delegate to them the needed methods.
"
Class {
	#name : 'ResourceRESTfulController',
	#superclass : 'Object',
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers',
	#'gs_options' : [
		'dbTransient'
	]
}

{ #category : 'testing' }
ResourceRESTfulController class >> isAbstract [

	<ignoreForCoverage>
	^ self = ResourceRESTfulController
]

{ #category : 'asserting' }
ResourceRESTfulController >> assertRequestIsAuthorizedTo: permission within: requestContext [

  ( requestContext includesPermission: permission ) ifFalse: [
      HTTPForbidden
        signal: 'Missing permissions'
        becauseScopeIsInsufficientFor: { permission }
        with: requestContext authChallenge
    ]
]

{ #category : 'private' }
ResourceRESTfulController >> jsonMediaType: aSubType vendoredBy: aVendorName version: aVersion [

	^ ( 'application/vnd.<1s>.<2s>+json' expandMacrosWith: aVendorName with: aSubType ) asMediaType
		version: aVersion
]

{ #category : 'accessing' }
ResourceRESTfulController >> routes [

	^ (UnaryMessageSendingCollector
		   sendingAllMessagesBeginningWith: 'declare'
		   andEndingWith: 'Route'
		   to: self) value
]

{ #category : 'configuring' }
ResourceRESTfulController >> serverUrl: aServerUrl [

	self subclassResponsibility
]
