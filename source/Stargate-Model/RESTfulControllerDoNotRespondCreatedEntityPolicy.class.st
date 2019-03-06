"
I'm a policy configuring a controller in such a way that responses for creation requests will not respond immediately with a representation of the created resource.
"
Class {
	#name : #RESTfulControllerDoNotRespondCreatedEntityPolicy,
	#superclass : #RESTfulControllerResourceCreationPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulControllerDoNotRespondCreatedEntityPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController
]

{ #category : #initialization }
RESTfulControllerDoNotRespondCreatedEntityPolicy >> initializeFor: aResourceController [

	resourceController := aResourceController
]

{ #category : #processing }
RESTfulControllerDoNotRespondCreatedEntityPolicy >> responseFor: aResource decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	^ ZnResponse created: ( resourceController locationOf: aResource )
]
