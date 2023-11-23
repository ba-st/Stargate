"
I'm an abstract policy controlling how to respond on the creation of new resources.
"
Class {
	#name : 'RESTfulControllerResourceCreationPolicy',
	#superclass : 'Object',
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'processing' }
RESTfulControllerResourceCreationPolicy >> responseFor: resource basedOn: httpRequest within: requestContext [

	self subclassResponsibility
]
