"
I represent a RESTful handler, and provide the base support to easily create specific controllers.
I provide the standard machinery to handle REST requests, and I'm supposed to be used from a controller.
"
Class {
	#name : #RESTfulRequestHandler,
	#superclass : #RESTfulRequestHandlerBehavior,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulRequestHandler class >> endpoint: aString
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: entityTagCalculator
	andLocationWith: aLocationResolverOptional [


	^ self new
		initializeEndpoint: aString
		paginationPolicy: aPaginationPolicy
		decodingRules: theDecodingRules
		encodingRules: theEncodingRules
		calculateEntityTagsWith: entityTagCalculator
		andLocationWith: aLocationResolverOptional
]
