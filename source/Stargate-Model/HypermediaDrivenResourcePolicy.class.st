Class {
	#name : #HypermediaDrivenResourcePolicy,
	#superclass : #HypermediaPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #'instance creation' }
HypermediaDrivenResourcePolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController 
]

{ #category : #configuring }
HypermediaDrivenResourcePolicy >> holdCollection: resourceCollection controlsBasedOn: httpRequest within: context [

	context holdAsHypermediaControls: (resourceController paginationPolicy addPaginationControlsTo: {('self' -> httpRequest absoluteUrl)} within: context).
	resourceCollection do: [ :resource | context holdAsHypermediaControls: (resourceController mediaControlsFor: resource) forSubresource: resource ]
]

{ #category : #configuring }
HypermediaDrivenResourcePolicy >> holdResource: resource controlsWithin: context [

	context holdAsHypermediaControls: (resourceController mediaControlsFor: resource)
]

{ #category : #initialization }
HypermediaDrivenResourcePolicy >> initializeFor: aResourceController [ 

	resourceController := aResourceController 
]
