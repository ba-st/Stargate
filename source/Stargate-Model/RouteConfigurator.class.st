"
I'm a web service route configurator.

I'm being used to configure a route on a Teapot server. I also know how to configure a route supporting cross-origin resource sharing.
"
Class {
	#name : #RouteConfigurator,
	#superclass : #Object,
	#instVars : [
		'teapot',
		'resourceController'
	],
	#category : #'Stargate-Model-Routing'
}

{ #category : #'instance creation' }
RouteConfigurator class >> configuring: aTeapot withRoutesDefinedOn: aResourceRESTfulController [

	^ self new initializeConfiguring: aTeapot withRoutesDefinedOn: aResourceRESTfulController
]

{ #category : #configuring }
RouteConfigurator >> configure [
	
	resourceController routes
		do: [ :routeSpecification | routeSpecification configureUsing: self ]
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureRouteFrom: aRouteSpecification [

	teapot addRouteMatchedBy: aRouteSpecification asRequestMatcher action: [ :request | 
		self withServerUrlDo: [ :url | request url: ( request url asHostedAt: url ) ].
		aRouteSpecification handler value: request value: HttpRequestContext new
		]
]

{ #category : #initialization }
RouteConfigurator >> initializeConfiguring: aTeapot withRoutesDefinedOn: aResourceRESTfulController [

	teapot := aTeapot.
	resourceController := aResourceRESTfulController.
	self withServerUrlDo: [ :url | resourceController serverUrl: url ].
]

{ #category : #'private - configuring' }
RouteConfigurator >> withServerUrlDo: aBlock [

	teapot server serverUrl ifNotNil: aBlock
]
