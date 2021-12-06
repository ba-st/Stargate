"
I'm an abstract class providing behavior for all the RESTful controllers related to operations and operation plugins.
"
Class {
	#name : #OperationsRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'authenticationFilter'
	],
	#category : #'Stargate-Model-Operations'
}

{ #category : #'instance creation' }
OperationsRESTfulController class >> authenticationFilterBasedOn: configuration [

	^ self new initializeAuthenticationFilterBasedOn: configuration
]

{ #category : #testing }
OperationsRESTfulController class >> isAbstract [

	^ self = OperationsRESTfulController
]

{ #category : #private }
OperationsRESTfulController >> assert: httpRequest isAuthorizedWithin: requestContext [

	( requestContext includesPermission: self requiredPermission )
		ifFalse: [ httpRequest abort: ZnResponse forbidden ]
]

{ #category : #initialization }
OperationsRESTfulController >> initializeAuthenticationFilterBasedOn: configuration [

	authenticationFilter := AuthenticationFilter basedOn: configuration
]

{ #category : #private }
OperationsRESTfulController >> requiredPermission [

	^ self subclassResponsibility
]

{ #category : #accessing }
OperationsRESTfulController >> routes [

	^ super routes
		collect: [ :routeSpecification | routeSpecification authenticatedBy: authenticationFilter ]
]

{ #category : #private }
OperationsRESTfulController >> typeIdConstraint [

	^ IsObject
]
