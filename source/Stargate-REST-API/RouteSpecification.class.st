Class {
	#name : #RouteSpecification,
	#superclass : #Object,
	#instVars : [
		'httpMethod',
		'handler',
		'urlTemplate'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: aResourceLocation evaluating: aBlock [

	^ self new initializeHandling: anHttpMethod at: aResourceLocation evaluating: aBlock
]

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: aResourceLocation sending: aMessage [

	^ self
		handling: anHttpMethod
		at: aResourceLocation
		evaluating:
			[ :service :httpRequest :context | service perform: aMessage with: httpRequest with: context ]
]

{ #category : #visiting }
RouteSpecification >> accept: aRouteConfigurator [

	aRouteConfigurator configureRoute: self  
]

{ #category : #decorating }
RouteSpecification >> asCorsAware [
	
	^ CorsAwareRouteSpecification for: self
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
