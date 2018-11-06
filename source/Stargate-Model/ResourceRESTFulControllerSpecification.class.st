"
I represent a RESTful Web Service spec.

I provide the supported mediaTypes for the service to be used during content negotiation and a mapping rule set used to encode/decode the supported representations.
I provide a set of routes to be used to configure Teapot.
"
Class {
	#name : #ResourceRESTFulControllerSpecification,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #acccessing }
ResourceRESTFulControllerSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]

{ #category : #acccessing }
ResourceRESTFulControllerSpecification >> mediaTypes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'MediaType' to: self) value
]

{ #category : #acccessing }
ResourceRESTFulControllerSpecification >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]
