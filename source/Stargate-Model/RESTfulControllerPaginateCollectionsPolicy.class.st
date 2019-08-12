"
I'm the policy indicating a RESTful controller to support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTfulControllerPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'defaultLimit',
		'requestHandler'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTfulControllerPaginateCollectionsPolicy class >> for: aRequestHandler with: aPaginationLimit [

	^ self new initializeFor: aRequestHandler with: aPaginationLimit
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: requestContext [

	^ mediaControls , requestContext paginationControls
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> affect: response within: requestContext [

	requestContext paginationControls
		do: [ :assoc | 
			response
				addLink:
					((ZnLink to: assoc value)
						rel: assoc key;
						yourself) ]
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: httpRequest [

	| pagination |

	pagination := [ self paginationFrom: httpRequest ]
		on: InstanceCreationFailed
		do: [ :error | HTTPClientError badRequest signal: error messageText ].
	^ requestHandler evaluateQuery: [ aQueryEvaluationBlock cull: pagination ]
]

{ #category : #initialization }
RESTfulControllerPaginateCollectionsPolicy >> initializeFor: aRequestHandler with: aPaginationLimit [

	requestHandler := aRequestHandler.
	defaultLimit := aPaginationLimit
]

{ #category : #private }
RESTfulControllerPaginateCollectionsPolicy >> paginationFrom: httpRequest [

	^ PaginationSpecification
		startingAt: (IsInteger parseString: (httpRequest at: #start ifAbsent: [ 1 ]))
		limitedTo: (IsInteger parseString: (httpRequest at: #limit ifAbsent: [ defaultLimit ]))
]
