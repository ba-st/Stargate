"
I'm a policy non-supporting hypermedia-driven RESTful controllers.
"
Class {
	#name : #NonHypermediaDrivenRESTfulControllerPolicy,
	#superclass : #RESTfulControllerHypermediaPolicy,
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #configuring }
NonHypermediaDrivenRESTfulControllerPolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [
]

{ #category : #configuring }
NonHypermediaDrivenRESTfulControllerPolicy >> holdResource: resource controlsWithin: context [
]
