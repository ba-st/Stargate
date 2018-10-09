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
RouteConfigurator >> configureAsCorsAwareRoute: aCorsAwareRouteSpecification [

	| specification |

	specification := aCorsAwareRouteSpecification specification.
	 
	routesAllowingCors
		at: specification resourceLocation
		ifPresent: [ :httpMethods | httpMethods add: specification httpMethod ]
		ifAbsentPut: (OrderedCollection with: specification httpMethod).

	specification accept: self
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
RouteConfigurator >> configureRoute: aRouteSpecification [

	teapot
		perform: (aRouteSpecification httpMethod , ':') asSymbol
		with:
			aRouteSpecification resourceLocation
				-> [ :request | 
					webService
						perform: aRouteSpecification message
						with: request
						with: HttpRequestContext new ]
]

{ #category : #initialization }
RouteConfigurator >> initializeAppliedTo: aTeapot sendingMessagesTo: aWebService [ 
	
	teapot := aTeapot .
	webService := aWebService.
	
	routesAllowingCors := Dictionary new.
]
