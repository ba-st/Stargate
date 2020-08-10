"
I'm a filter builder. I aim to provide a clean interface to configure CORS support during the configuration of a HTTPBasedRESTfulAPI instance.
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

	^ self new initializeUsing: aControllerCollection
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

{ #category : #initialization }
CrossOriginResourceSharingFilterBuilder >> allowedMethodsFrom: aControllerCollection [

	| routes allowedMethods |

	routes := OrderedCollection new.

	aControllerCollection do: [ :controller | routes addAll: controller routes ].

	allowedMethods := routes
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

{ #category : #building }
CrossOriginResourceSharingFilterBuilder >> buildActualRequestFilter [

	^ CrossOriginResourceSharingFilter handleActualRequestByEvaluating: actualRequestHandlerBuilder build
]

{ #category : #building }
CrossOriginResourceSharingFilterBuilder >> buildPreflightFilter [

	^ CrossOriginResourceSharingFilter handlePreflightByEvaluating: preflightHandlerBuilder build
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
	self allowedMethodsFrom: aControllerCollection
]
