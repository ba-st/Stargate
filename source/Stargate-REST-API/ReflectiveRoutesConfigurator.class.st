Class {
	#name : #ReflectiveRoutesConfigurator,
	#superclass : #Object,
	#instVars : [
		'teapot'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
ReflectiveRoutesConfigurator class >> appliedTo: aTeapot [ 
	
	^ self new initializeAppliedTo: aTeapot 
]

{ #category : #configuring }
ReflectiveRoutesConfigurator >> addRoutesOf: aWebService [

	| routeConfigurator |

	routeConfigurator := RouteConfigurator
		appliedTo: teapot
		sendingMessagesTo: aWebService.

	(self specifiedRoutesFor: aWebService)
		do: [ :routeSpecification | routeSpecification accept: routeConfigurator ].

	routeConfigurator configureCrossOriginSharingRoutes
]

{ #category : #initialization }
ReflectiveRoutesConfigurator >> initializeAppliedTo: aTeapot [ 
	
	teapot := aTeapot
]

{ #category : #accessing }
ReflectiveRoutesConfigurator >> specifiedRoutesFor: aWebService [

	^ (UnaryMessageSendingCollector
		sendingAllMessagesEndingWith: 'Route'
		to: aWebService specification) value
]
