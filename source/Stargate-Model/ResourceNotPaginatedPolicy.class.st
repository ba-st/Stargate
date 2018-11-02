Class {
	#name : #ResourceNotPaginatedPolicy,
	#superclass : #ResourcePaginationPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
ResourceNotPaginatedPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController
]

{ #category : #applying }
ResourceNotPaginatedPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls 
]

{ #category : #applying }
ResourceNotPaginatedPolicy >> affect: response within: aContext [
]

{ #category : #applying }
ResourceNotPaginatedPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: aQueryEvaluationBlock
]

{ #category : #'as yet unclassified' }
ResourceNotPaginatedPolicy >> initializeFor: aResourceController [

	resourceController := aResourceController 
]
