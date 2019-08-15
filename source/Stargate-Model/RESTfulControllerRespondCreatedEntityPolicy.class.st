"
I'm a policy configuring a controller in such a way that responses for creation requests will respond immediately with a representation of the created resource.
"
Class {
	#name : #RESTfulControllerRespondCreatedEntityPolicy,
	#superclass : #RESTfulControllerResourceCreationPolicy,
	#instVars : [
		'requestHandler',
		'targetMediaType'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulControllerRespondCreatedEntityPolicy class >> for: aRequestHandler encodedAs: aTargetMediaType [

	^ self new initializeFor: aRequestHandler encodedAs: aTargetMediaType
]

{ #category : #initialization }
RESTfulControllerRespondCreatedEntityPolicy >> initializeFor: aRequestHandler encodedAs: aTargetMediaType [

	requestHandler := aRequestHandler.
	targetMediaType := aTargetMediaType
]

{ #category : #processing }
RESTfulControllerRespondCreatedEntityPolicy >> responseFor: resource basedOn: httpRequest within: requestContext [

	| response |

	response := ZnResponse
		created: ( requestHandler locationOf: resource within: requestContext )
		entity: ( requestHandler encodeResource: resource to: targetMediaType within: requestContext ).
	requestHandler
		putEntityTagOf: resource
		encodedAs: targetMediaType
		in: response
		within: requestContext.
	^ response
]
