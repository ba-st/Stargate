"
I'm a policy indicating a RESTful controller if it must support or not an hypermedia driven implementation
"
Class {
	#name : #RESTfulControllerHypermediaPolicy,
	#superclass : #Object,
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #configuring }
RESTfulControllerHypermediaPolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [

	self subclassResponsibility 
]

{ #category : #configuring }
RESTfulControllerHypermediaPolicy >> holdResource: resource controlsWithin: context [

	self subclassResponsibility 
]
