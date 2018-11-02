Class {
	#name : #NoHypermediaResourcePolicy,
	#superclass : #HypermediaPolicy,
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #configuring }
NoHypermediaResourcePolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [
]

{ #category : #configuring }
NoHypermediaResourcePolicy >> holdResource: resource controlsWithin: context [
]
