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

	<ignoreForCoverage>
	^ self = OperationsRESTfulController
]

{ #category : #private }
OperationsRESTfulController >> assert: httpRequest isAuthorizedTo: permission within: requestContext [

	( requestContext includesPermission: permission ) ifFalse: [ 
		httpRequest abort: ZnResponse forbidden ]
]

{ #category : #private }
OperationsRESTfulController >> assert: httpRequest isAuthorizedWithin: requestContext [

	self assert: httpRequest isAuthorizedTo: self requiredPermission within: requestContext
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
