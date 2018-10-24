"
I will provide the preferred media type to use for processing an HTTP Request given an available media type list
"
Class {
	#name : #RESTfulWebServiceAcceptNegotiator,
	#superclass : #Object,
	#instVars : [
		'availableMediaTypes'
	],
	#category : #'Stargate-REST-API-Model'
}

{ #category : #'instance creation' }
RESTfulWebServiceAcceptNegotiator class >> basedOn: aMediaTypeCollection [

	^ self new initializeBasedOn: aMediaTypeCollection
]

{ #category : #'initialize - release' }
RESTfulWebServiceAcceptNegotiator >> initializeBasedOn: aMediaTypeCollection [

	availableMediaTypes := aMediaTypeCollection 
]

{ #category : #querying }
RESTfulWebServiceAcceptNegotiator >> preferredMediaTypeFor: anHttpRequest [

	| acceptableMediaTypes groupedAcceptableMediaTypes |

	acceptableMediaTypes := (anHttpRequest accept splitOn: ',') collect: [ :type | type asMediaType ].
	groupedAcceptableMediaTypes := acceptableMediaTypes groupedBy: [ :mediaType | mediaType quality ].
	(groupedAcceptableMediaTypes keys sorted reverse)
		do: [ :quality | 
			((groupedAcceptableMediaTypes at: quality) sorted: #precedence descending)
				do: [ :acceptable | 
					| options |

					options := availableMediaTypes select: [ :available | available canAccept: acceptable ].
					"Here we need to handle the versioning part"
					options ifNotEmpty: [ ^ (options sorted: #precedence descending) first ] ] ].
	HTTPClientError signalUnsupportedMediaType: acceptableMediaTypes
]
