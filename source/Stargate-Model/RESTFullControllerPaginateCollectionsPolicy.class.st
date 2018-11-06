"
I'm the policy indicating a RESTful controller to support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTFullControllerPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'resourceController',
		'defaultLimit'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTFullControllerPaginateCollectionsPolicy class >> for: aResourceController with: aPaginationLimit [

	^ self new initializeFor: aResourceController with: aPaginationLimit
]

{ #category : #applying }
RESTFullControllerPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls , aContext paginationControls
]

{ #category : #applying }
RESTFullControllerPaginateCollectionsPolicy >> affect: response within: aContext [

	aContext paginationControls
		do: [ :assoc | 
			response
				addLink:
					((ZnLink to: assoc value)
						rel: assoc key;
						yourself) ]
]

{ #category : #applying }
RESTFullControllerPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: [ aQueryEvaluationBlock cull: (self paginationFrom: anHttpRequest) ]
]

{ #category : #initialization }
RESTFullControllerPaginateCollectionsPolicy >> initializeFor: aResourceController with: aPaginationLimit [

	resourceController := aResourceController.
	defaultLimit := aPaginationLimit
]

{ #category : #private }
RESTFullControllerPaginateCollectionsPolicy >> paginationFrom: anHttpRequest [

	^ PaginationSpec
		startingAt: (IsInteger parseString: (anHttpRequest at: #start ifAbsent: [ 1 ]))
		limitedTo: (IsInteger parseString: (anHttpRequest at: #limit ifAbsent: [ defaultLimit ]))
]
