"
I'm a web service route configurator.

I'm being used to configure a route on a Teapot server. I also know how to configure a route supporting cross-origin resource sharing.
"
Class {
	#name : #RouteConfigurator,
	#superclass : #Object,
	#instVars : [
		'teapot',
		'routesAllowingCors',
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
		do: [ :routeSpecification | routeSpecification configureUsing: self ].
	self configurePreflightRoutes
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureCrossOriginResourceSharingAwareRouteFrom: aCorsAwareRouteSpecification [

	| specification |

	specification := aCorsAwareRouteSpecification specification.
	self register: specification httpMethod asAllowedTo: specification urlTemplate.
	specification configureUsing: self
]

{ #category : #'private - configuring' }
RouteConfigurator >> configurePreflightRoutes [

	routesAllowingCors
		keysAndValuesDo:
			[ :location :httpMethods | teapot OPTIONS: location -> ( CrossOriginResourceSharingPreflightHandler allowing: httpMethods ) ]
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureRouteFrom: aRouteSpecification [

	teapot
		addRouteMethod: (TeaMethodMatcher exactly: aRouteSpecification httpMethod asSymbol)
		pattern: aRouteSpecification urlTemplate
		action: [ :request | 
			self withServerUrlDo: [ :url | request url: ( request url asHostedAt: url ) ].
			aRouteSpecification handler value: request value: HttpRequestContext new
			]
]

{ #category : #initialization }
RouteConfigurator >> initializeConfiguring: aTeapot withRoutesDefinedOn: aResourceRESTfulController [

	teapot := aTeapot.
	resourceController := aResourceRESTfulController.
	self withServerUrlDo: [ :url | resourceController serverUrl: url ].
	routesAllowingCors := Dictionary new
]

{ #category : #'private - configuring' }
RouteConfigurator >> register: aMethod asAllowedTo: anEndpoint [

	routesAllowingCors
		at: anEndpoint
		ifPresent: [ :httpMethods | httpMethods add: aMethod ]
		ifAbsentPut: [ OrderedCollection with: aMethod ]
]

{ #category : #'private - configuring' }
RouteConfigurator >> withServerUrlDo: aBlock [

	teapot server serverUrl ifNotNil: aBlock
]
