"
I'm the policy indicating a RESTful controller to support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTfulControllerPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'resourceController',
		'defaultLimit'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTfulControllerPaginateCollectionsPolicy class >> for: aResourceController with: aPaginationLimit [

	^ self new initializeFor: aResourceController with: aPaginationLimit
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls , aContext paginationControls
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> affect: response within: aContext [

	aContext paginationControls
		do: [ :assoc | 
			response
				addLink:
					((ZnLink to: assoc value)
						rel: assoc key;
						yourself) ]
]

{ #category : #applying }
RESTfulControllerPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: [ aQueryEvaluationBlock cull: (self paginationFrom: anHttpRequest) ]
]

{ #category : #initialization }
RESTfulControllerPaginateCollectionsPolicy >> initializeFor: aResourceController with: aPaginationLimit [

	resourceController := aResourceController.
	defaultLimit := aPaginationLimit
]

{ #category : #private }
RESTfulControllerPaginateCollectionsPolicy >> paginationFrom: anHttpRequest [

	^ PaginationSpecification
		startingAt: (IsInteger parseString: (anHttpRequest at: #start ifAbsent: [ 1 ]))
		limitedTo: (IsInteger parseString: (anHttpRequest at: #limit ifAbsent: [ defaultLimit ]))
]
