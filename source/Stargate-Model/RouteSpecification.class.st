"
I'm an spec for a route. 
I provide a URL template, an HTTP method and a handler to invoke for this route.
"
Class {
	#name : #RouteSpecification,
	#superclass : #AbstractRouteSpecification,
	#instVars : [
		'httpMethod',
		'handler',
		'urlTemplate'
	],
	#category : #'Stargate-Model-Routing'
}

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: anUrlTemplate evaluating: aBlock [

	^ self new initializeHandling: anHttpMethod at: anUrlTemplate evaluating: aBlock
]

{ #category : #decorating }
RouteSpecification >> asCorsAware [
	
	^ CrossOriginResourceSharingAwareRouteSpecification decorating: self
]

{ #category : #configuring }
RouteSpecification >> authenticatedBy: anAuthorizationFilter [

	^ self class
		handling: httpMethod
		at: urlTemplate
		evaluating: [ :httpRequest :requestContext | 
			anAuthorizationFilter evaluateActionOnRequest: httpRequest within: requestContext.
			handler value: httpRequest value: requestContext
			]
]

{ #category : #configuring }
RouteSpecification >> configureUsing: aRouteConfigurator [ 

	aRouteConfigurator configureRouteFrom: self  
]

{ #category : #accessing }
RouteSpecification >> handler [

	^ handler
]

{ #category : #accessing }
RouteSpecification >> httpMethod [

	^ httpMethod
]

{ #category : #initialization }
RouteSpecification >> initializeHandling: anHttpMethod at: anURLTemplate evaluating: aBlock [

	httpMethod := anHttpMethod.
	urlTemplate := anURLTemplate.
	handler := aBlock
]

{ #category : #accessing }
RouteSpecification >> urlTemplate [

	^ urlTemplate
]
