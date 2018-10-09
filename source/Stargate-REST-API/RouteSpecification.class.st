Class {
	#name : #RouteSpecification,
	#superclass : #Object,
	#instVars : [
		'httpMethod',
		'resourceLocation',
		'message'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: aResourceLocation sending: aMessage [

	^ self new initializeHandling: anHttpMethod at: aResourceLocation sending: aMessage
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
RouteSpecification >> httpMethod [

	^ httpMethod
]

{ #category : #initialization }
RouteSpecification >> initializeHandling: anHttpMethod at: aResourceLocation sending: aMessage [

	httpMethod := anHttpMethod.
	resourceLocation := aResourceLocation.
	message := aMessage
]

{ #category : #accessing }
RouteSpecification >> message [

	^ message
]

{ #category : #accessing }
RouteSpecification >> resourceLocation [

	^ resourceLocation
]
