"
I represent a RESTful Web Service spec.

I provide the supported mediaTypes for the service to be used during content negotiation and a mapping rule set used to encode/decode the supported representations.
I provide a set of routes to be used to configure Teapot.
"
Class {
	#name : #ResourceRESTfulControllerSpecification,
	#superclass : #Object,
	#category : #'Stargate-Deprecated-V3'
}

{ #category : #deprecation }
ResourceRESTfulControllerSpecification class >> isDeprecated [

	^ true
]
