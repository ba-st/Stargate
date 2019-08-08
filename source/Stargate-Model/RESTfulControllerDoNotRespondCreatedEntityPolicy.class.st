"
I'm a policy configuring a controller in such a way that responses for creation requests will not respond immediately with a representation of the created resource.
"
Class {
	#name : #RESTfulControllerDoNotRespondCreatedEntityPolicy,
	#superclass : #RESTfulControllerResourceCreationPolicy,
	#instVars : [
		'requestHandler'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulControllerDoNotRespondCreatedEntityPolicy class >> for: aRequestHandler [

	^ self new initializeFor: aRequestHandler
]

{ #category : #initialization }
RESTfulControllerDoNotRespondCreatedEntityPolicy >> initializeFor: aRequestHandler [

	requestHandler := aRequestHandler
]

{ #category : #processing }
RESTfulControllerDoNotRespondCreatedEntityPolicy >> responseFor: resource basedOn: httpRequest within: requestContext [

	^ ZnResponse created: ( requestHandler locationOf: resource within: requestContext )
]
