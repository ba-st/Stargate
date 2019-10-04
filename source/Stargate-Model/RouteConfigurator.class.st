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
RouteConfigurator class >> appliedTo: aTeapot sendingMessagesTo: aResourceRESTfulController [

	^ self new initializeAppliedTo: aTeapot sendingMessagesTo: aResourceRESTfulController
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureCorsAwareRouteFrom: aCorsAwareRouteSpecification [

	| specification |

	specification := aCorsAwareRouteSpecification specification.

	routesAllowingCors
		at: specification urlTemplate
		ifPresent: [ :httpMethods | httpMethods add: specification httpMethod ]
		ifAbsentPut: [ OrderedCollection with: specification httpMethod ].

	specification configureUsing: self
]

{ #category : #configuring }
RouteConfigurator >> configureCrossOriginSharingRoutes [

	routesAllowingCors
		keysAndValuesDo:
			[ :location :httpMethods | teapot OPTIONS: location -> ( CrossOriginResourceSharingPreflightHandler allowing: httpMethods ) ]
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureRouteFrom: aRouteSpecification [

	teapot
		perform: ( '<1s>:' expandMacrosWith: aRouteSpecification httpMethod ) asSymbol
		with:
			aRouteSpecification urlTemplate
				-> [ :request | 
					self withServerUrlDo: [ :url | request url: ( request url asHostedAt: url ) ].
					aRouteSpecification handler value: request value: HttpRequestContext new
					]
]

{ #category : #initialization }
RouteConfigurator >> initializeAppliedTo: aTeapot sendingMessagesTo: aResourceRESTfulController [

	teapot := aTeapot.
	resourceController := aResourceRESTfulController.
	self withServerUrlDo: [ :url | resourceController serverUrl: url ].
	routesAllowingCors := Dictionary new
]

{ #category : #'private - configuring' }
RouteConfigurator >> withServerUrlDo: aBlock [

	teapot server serverUrl ifNotNil: aBlock
]
