"
I represent a RESTful Web Service spec.

I provide the supported mediaTypes for the service to be used during content negotiation and a mapping rule set used to encode/decode the supported representations.
I provide a set of routes to be used to configure Teapot.
"
Class {
	#name : #ResourceRESTfulControllerSpecification,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #private }
ResourceRESTfulControllerSpecification >> jsonMediaType: aSubType vendoredBy: aVendorName version: aVersion [

	^ ( 'application/vnd.<1s>.<2s>+json' expandMacrosWith: aVendorName with: aSubType ) asMediaType
		version: aVersion
]

{ #category : #acccessing }
ResourceRESTfulControllerSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]

{ #category : #acccessing }
ResourceRESTfulControllerSpecification >> mediaTypes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'MediaType' to: self) value
]

{ #category : #acccessing }
ResourceRESTfulControllerSpecification >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]
