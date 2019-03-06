"
I'm an abstract policy controlling how to respond on the creation of new resources. 
"
Class {
	#name : #RESTfulControllerResourceCreationPolicy,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #processing }
RESTfulControllerResourceCreationPolicy >> responseFor: aResource decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self subclassResponsibility
]
