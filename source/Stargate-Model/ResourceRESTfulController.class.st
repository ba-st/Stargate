"
I represent a RESTful Controller.
I will provide some routes to be configured in a Teapot Server.
My subclasses must create one or more RESTfulRequestHandler (usually with the available builder), 
and delegate to them the needed methods.
"
Class {
	#name : #ResourceRESTfulController,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #private }
ResourceRESTfulController >> jsonMediaType: aSubType vendoredBy: aVendorName version: aVersion [

	^ ( 'application/vnd.<1s>.<2s>+json' expandMacrosWith: aVendorName with: aSubType ) asMediaType
		version: aVersion
]

{ #category : #accessing }
ResourceRESTfulController >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]

{ #category : #configuring }
ResourceRESTfulController >> serverUrl: aServerUrl [

	self subclassResponsibility
]
