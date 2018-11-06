"
I'm a policy supporting hypermedia-driven RESTful controllers.
"
Class {
	#name : #HypermediaDrivenRESTfulControllerPolicy,
	#superclass : #HypermediaPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #'instance creation' }
HypermediaDrivenRESTfulControllerPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController 
]

{ #category : #configuring }
HypermediaDrivenRESTfulControllerPolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [

	context holdAsHypermediaControls: (resourceController paginationPolicy addPaginationControlsTo: {('self' -> httpRequest absoluteUrl)} within: context).
	resourceCollection do: [ :resource | context holdAsHypermediaControls: (resourceController mediaControlsFor: resource) forSubresource: resource ]
]

{ #category : #configuring }
HypermediaDrivenRESTfulControllerPolicy >> holdResource: resource controlsWithin: context [

	context holdAsHypermediaControls: (resourceController mediaControlsFor: resource)
]

{ #category : #initialization }
HypermediaDrivenRESTfulControllerPolicy >> initializeFor: aResourceController [ 

	resourceController := aResourceController 
]
