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
RESTfulControllerRespondCreatedEntityPolicy class >> for: aRequestHandler [

	^ self new initializeFor: aRequestHandler
]

{ #category : #initialization }
RESTfulControllerRespondCreatedEntityPolicy >> initializeFor: aRequestHandler [

	requestHandler := aRequestHandler
]

{ #category : #processing }
RESTfulControllerRespondCreatedEntityPolicy >> responseFor: resource basedOn: httpRequest within: requestContext [

	| response |

	response := ZnResponse
		created: ( requestHandler locationOf: resource within: requestContext )
		entity: ( requestHandler encodeResource: resource within: requestContext ).
	requestHandler putEntityTagOf: resource in: response within: requestContext.
	^ response
]
