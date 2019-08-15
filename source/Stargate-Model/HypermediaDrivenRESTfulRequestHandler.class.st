"
I represent a RESTful handler supporting hypermedia driven controllers.
"
Class {
	#name : #HypermediaDrivenRESTfulRequestHandler,
	#superclass : #RESTfulRequestHandlerBehavior,
	#instVars : [
		'mediaControlsFactory'
	],
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #'instance creation' }
HypermediaDrivenRESTfulRequestHandler class >> resourceLocator: aResouceLocator paginationPolicy: aPaginationPolicy decodingRules: theDecodingRules encodingRules: theEncodingRules calculateEntityTagsWith: entityTagCalculator drivenBy: aMediaControlsFactory [

	^ self new
		initializeResourceLocator: aResouceLocator
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: entityTagCalculator
		drivenBy: aMediaControlsFactory
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> encodeResource: resource to: mediaType within: requestContext [

	self holdResource: resource controlsWithin: requestContext.
	^ super encodeResource: resource to: mediaType within: requestContext
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> encodeResourceCollection: resourceCollection to: mediaType basedOn: httpRequest within: requestContext [

	requestContext
		holdAsHypermediaControls:
			( self paginationPolicy
				addPaginationControlsTo: ( Array with: 'self' -> httpRequest absoluteUrl )
				within: requestContext )
		for: resourceCollection.

	resourceCollection do: [ :resource | self holdResource: resource controlsWithin: requestContext ].

	^ super
		encodeResourceCollection: ( ResourceCollection wrapping: resourceCollection )
		to: mediaType
		basedOn: httpRequest
		within: requestContext
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> holdResource: resource controlsWithin: requestContext [

	requestContext
		holdAsHypermediaControls: ( self mediaControlsFor: resource within: requestContext )
		for: resource
]

{ #category : #initialization }
HypermediaDrivenRESTfulRequestHandler >> initializeResourceLocator: aResouceLocator
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: anEntityTagCalculator
	drivenBy: aMediaControlsFactory [

	self
		initializeResourceLocator: aResouceLocator
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: anEntityTagCalculator.

	mediaControlsFactory := aMediaControlsFactory
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> mediaControlsFor: resource within: requestContext [

	^ mediaControlsFactory
		cull: MediaControlsBuilder new
		cull: resource
		cull: requestContext
		cull: ( self locationOf: resource within: requestContext )
]
