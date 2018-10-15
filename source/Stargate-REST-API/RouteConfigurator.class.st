"
I'm a web service route configurator.

I'm being used to configure a route on a Teapot server. I also know how to configure a route supporting cross-origin resource sharing.
"
Class {
	#name : #RouteConfigurator,
	#superclass : #Object,
	#instVars : [
		'teapot',
		'webService',
		'routesAllowingCors'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
RouteConfigurator class >> appliedTo: aTeapot sendingMessagesTo: aWebService [

	^ self new initializeAppliedTo: aTeapot sendingMessagesTo: aWebService
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureCorsAwareRouteFrom: aCorsAwareRouteSpecification [

	| specification |

	specification := aCorsAwareRouteSpecification specification.

	routesAllowingCors
		at: specification urlTemplate
		ifPresent: [ :httpMethods | httpMethods add: specification httpMethod ]
		ifAbsentPut: (OrderedCollection with: specification httpMethod).

	specification configureUsing: self
]

{ #category : #configuring }
RouteConfigurator >> configureCrossOriginSharingRoutes [

	routesAllowingCors keys
		do: [ :resourceLocation | 
			teapot
				OPTIONS:
					resourceLocation
						-> (CrossOriginResourceSharingHandler allowing: (routesAllowingCors at: resourceLocation)) ]
]

{ #category : #'private - configuring' }
RouteConfigurator >> configureRouteFrom: aRouteSpecification [

	teapot
		perform: ('<1s>:' expandMacrosWith: aRouteSpecification httpMethod) asSymbol
		with:
			aRouteSpecification urlTemplate
				-> [ :request | aRouteSpecification handler value: webService value: request value: HttpRequestContext new ]
]

{ #category : #initialization }
RouteConfigurator >> initializeAppliedTo: aTeapot sendingMessagesTo: aWebService [

	teapot := aTeapot.
	webService := aWebService.
	teapot server serverUrl ifNotNil: [ :url | webService serverUrl: url ].
	routesAllowingCors := Dictionary new
]
