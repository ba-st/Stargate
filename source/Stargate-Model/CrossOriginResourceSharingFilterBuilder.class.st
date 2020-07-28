"
I'm a filter builder. I aimed to provide a clean interface to configure CORS during the instantiation of a HTTPBasedRESTfulAPI
"
Class {
	#name : #CrossOriginResourceSharingFilterBuilder,
	#superclass : #Object,
	#instVars : [
		'actualRequestHandlerBuilder',
		'preflightHandlerBuilder'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingFilterBuilder class >> using: aControllerCollection [

	^ self new inializeUsing: aControllerCollection
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> allowAnyOrigin [
	
	preflightHandlerBuilder allowAnyOrigin.
	actualRequestHandlerBuilder allowAnyOrigin 
	
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> allowCredentials [

	actualRequestHandlerBuilder allowCredentials.
	preflightHandlerBuilder allowCredentials
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> allowOnlyFrom: origins [ 
	
	preflightHandlerBuilder allowOnlyFrom: origins.
	actualRequestHandlerBuilder allowOnlyFrom: origins
]

{ #category : #building }
CrossOriginResourceSharingFilterBuilder >> buildActualRequestFilter [

	^ CrossOriginResourceSharingFilter handleActualRequestByEvaluating: actualRequestHandlerBuilder build
]

{ #category : #building }
CrossOriginResourceSharingFilterBuilder >> buildPreflightFilter [

	^ CrossOriginResourceSharingFilter handlePreflightByEvaluating: preflightHandlerBuilder build
]

{ #category : #initialization }
CrossOriginResourceSharingFilterBuilder >> configureAllowedMethodsFrom: aControllerCollection [

	| nonOperationalRoutes allowedMethods |

	nonOperationalRoutes := OrderedCollection new.

	aControllerCollection
		reject: [ :controller | controller isA: OperationsRESTfulController ]
		thenCollect: [ :controller | nonOperationalRoutes addAll: controller routes ].

	allowedMethods := nonOperationalRoutes
		inject: Dictionary new
		into: [ :methodsByRoute :route | 
			methodsByRoute
				at: route urlTemplate
					ifPresent: [ :methods | methods add: route httpMethod ]
					ifAbsentPut: ( OrderedCollection with: route httpMethod );
				yourself
			].

	preflightHandlerBuilder allowMethods: allowedMethods
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> doNotCache [
	
	preflightHandlerBuilder doNotCache 
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> expireIn: aDuration [ 
	
	preflightHandlerBuilder expireIn: aDuration
	
]

{ #category : #configuring }
CrossOriginResourceSharingFilterBuilder >> expose: headers [ 
	
	preflightHandlerBuilder expose: headers.
	actualRequestHandlerBuilder expose: headers
]

{ #category : #initialization }
CrossOriginResourceSharingFilterBuilder >> inializeUsing: aControllerCollection [

	preflightHandlerBuilder := CrossOriginResourceSharingPreflightHandlerBuilder new.
	actualRequestHandlerBuilder := CrossOriginResourceSharingActualRequestHandlerBuilder new.
	self configureAllowedMethodsFrom: aControllerCollection
]