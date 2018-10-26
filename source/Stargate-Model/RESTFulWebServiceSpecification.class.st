"
I represent a RESTful Web Service spec.

I provide the supported mediaTypes for the service to be used during content negotiation and a mapping rule set used to encode/decode the supported representations.
I provide a set of routes to be used to configure Teapot.
"
Class {
	#name : #RESTFulWebServiceSpecification,
	#superclass : #Object,
	#category : #'Stargate-Model-Services'
}

{ #category : #acccessing }
RESTFulWebServiceSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]

{ #category : #acccessing }
RESTFulWebServiceSpecification >> mediaTypes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'MediaType' to: self) value
]

{ #category : #acccessing }
RESTFulWebServiceSpecification >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]
