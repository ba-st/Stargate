"
I'm a policy configuring a controller in such a way that responses for creation requests will respond immediately with a representation of the created resource.
"
Class {
	#name : #RESTfulControllerRespondCreatedEntityPolicy,
	#superclass : #RESTfulControllerResourceCreationPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulControllerRespondCreatedEntityPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController
]

{ #category : #initialization }
RESTfulControllerRespondCreatedEntityPolicy >> initializeFor: aResourceController [

	resourceController := aResourceController
]

{ #category : #processing }
RESTfulControllerRespondCreatedEntityPolicy >> responseFor: aResource decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	| response |

	resourceController hypermediaPolicy holdResource: aResource controlsWithin: aContext.
	response := ZnResponse
		created: ( resourceController locationOf: aResource within: aContext )
		entity:
			( resourceController
				encode: aResource
				at: aKey
				to: anHttpRequest contentType
				within: aContext ).
	resourceController
		putEntityTagOf: aResource
		encodedAs: anHttpRequest contentType
		in: response
		within: aContext.
	^ response
]
