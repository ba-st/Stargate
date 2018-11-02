Class {
	#name : #ResourceIsPaginatedPolicy,
	#superclass : #ResourcePaginationPolicy,
	#instVars : [
		'resourceController',
		'defaultLimit'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
ResourceIsPaginatedPolicy class >> for: aResourceController with: aPaginationLimit [

	^ self new initializeFor: aResourceController with: aPaginationLimit
]

{ #category : #applying }
ResourceIsPaginatedPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls , aContext paginationControls
]

{ #category : #applying }
ResourceIsPaginatedPolicy >> affect: response within: aContext [

	aContext paginationControls
		do: [ :assoc | 
			response
				addLink:
					((ZnLink to: assoc value)
						rel: assoc key;
						yourself) ]
]

{ #category : #applying }
ResourceIsPaginatedPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: [ aQueryEvaluationBlock cull: (self paginationFrom: anHttpRequest) ]
]

{ #category : #'as yet unclassified' }
ResourceIsPaginatedPolicy >> initializeFor: aResourceController with: aPaginationLimit [

	resourceController := aResourceController.
	defaultLimit := aPaginationLimit
]

{ #category : #private }
ResourceIsPaginatedPolicy >> paginationFrom: anHttpRequest [

	^ PaginationSpec
		startingAt: (IsInteger parseString: (anHttpRequest at: #start ifAbsent: [ 1 ]))
		limitedTo: (IsInteger parseString: (anHttpRequest at: #limit ifAbsent: [ defaultLimit ]))
]
