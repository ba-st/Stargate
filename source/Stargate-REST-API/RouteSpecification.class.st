Class {
	#name : #RouteSpecification,
	#superclass : #Object,
	#instVars : [
		'httpMethod',
		'handler',
		'urlTemplate'
	],
	#category : #'Stargate-REST-API-Routing'
}

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: anUrlTemplate evaluating: aBlock [

	^ self new initializeHandling: anHttpMethod at: anUrlTemplate evaluating: aBlock
]

{ #category : #'instance creation' }
RouteSpecification class >> handling: anHttpMethod at: aUrlTemplate sending: aMessage [

	^ self
		handling: anHttpMethod
		at: aUrlTemplate
		evaluating:
			[ :service :httpRequest :context | service perform: aMessage with: httpRequest with: context ]
]

{ #category : #decorating }
RouteSpecification >> asCorsAware [
	
	^ CrossOriginResourceSharingAwareRouteSpecification decorating: self
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
