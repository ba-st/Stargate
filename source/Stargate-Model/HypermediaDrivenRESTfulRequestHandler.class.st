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
HypermediaDrivenRESTfulRequestHandler class >> resourceLocator: aResouceLocator paginationPolicy: aPaginationPolicy decodingRules: theDecodingRules encodingRules: theEncodingRules calculateEntityTagsWith: entityTagCalculator cachingDirectives: theCachingDirectives allowedLanguageTags: allowedLanguageTags drivenBy: aMediaControlsFactory handleErrorsWith: anExceptionHandler [

	^ self new
		initializeResourceLocator: aResouceLocator
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: entityTagCalculator
		cachingDirectives: theCachingDirectives
		allowedLanguageTags: allowedLanguageTags
		drivenBy: aMediaControlsFactory
		handleErrorsWith: anExceptionHandler
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> encodeResource: resource as: mediaType within: requestContext [

	self holdResource: resource controlsWithin: requestContext.
	^ super encodeResource: resource as: mediaType within: requestContext
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> encodeResourceCollection: resourceCollection basedOn: httpRequest within: requestContext [

	requestContext
		holdAsHypermediaControls:
			( self paginationPolicy
				addPaginationControlsTo: ( Array with: 'self' -> httpRequest absoluteUrl )
				within: requestContext )
		for: resourceCollection.
	resourceCollection do: [ :resource | self holdResource: resource controlsWithin: requestContext ].
	^ super
		encodeResourceCollection: ( ResourceCollection wrapping: resourceCollection )
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
	cachingDirectives: theCachingDirectives
	allowedLanguageTags: allowedLanguageTags
	drivenBy: aMediaControlsFactory
	handleErrorsWith: anExceptionHandler [


	self
		initializeResourceLocator: aResouceLocator
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: anEntityTagCalculator
		cachingDirectives: theCachingDirectives
		allowedLanguageTags: allowedLanguageTags
		handleErrorsWith: anExceptionHandler.

	mediaControlsFactory := aMediaControlsFactory
]

{ #category : #private }
HypermediaDrivenRESTfulRequestHandler >> mediaControlsFor: resource within: requestContext [

	^ mediaControlsFactory
		cull: ( MediaControlsBuilder locatingResourcesWith: resourceLocator )
		cull: resource
		cull: requestContext
		cull: ( self locationOf: resource within: requestContext )
]
