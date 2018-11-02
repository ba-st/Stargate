Class {
	#name : #HypermediaPolicy,
	#superclass : #Object,
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #configuring }
HypermediaPolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [

	self subclassResponsibility 
]

{ #category : #configuring }
HypermediaPolicy >> holdResource: resource controlsWithin: context [

	self subclassResponsibility 
]
