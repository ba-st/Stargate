"
I'm a reflective configurator of web service routes.

I'm being used to configure a Teapot server routes reflectively. I expect web service specification declare its routes on messages that follow the pattern #*Route
"
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
		do: [ :routeSpecification | routeSpecification configureUsing: routeConfigurator ].

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
