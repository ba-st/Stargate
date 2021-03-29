"
I'm an spec for a route. 
I provide a URL template, an HTTP method and a handler to invoke for this route.
"
Class {
	#name : #RouteSpecification,
	#superclass : #Object,
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

{ #category : #converting }
RouteSpecification >> asCorsAware [

	self
		deprecated: 'CORS has to be configured site-wide since v6'
		transformWith: '`@receiver asCorsAware' -> '@receiver'.

	^ self
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
	handler := [ :httpRequest :requestContext | 
		httpRequest setUrlTemplate: urlTemplate.
		aBlock value: httpRequest value: requestContext
	]
]

{ #category : #accessing }
RouteSpecification >> urlTemplate [

	^ urlTemplate
]
