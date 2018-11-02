Class {
	#name : #ResourcePaginationPolicy,
	#superclass : #Object,
	#category : #'Stargate-Model-Pagination'
}

{ #category : #applying }
ResourcePaginationPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ self subclassResponsibility 
]

{ #category : #applying }
ResourcePaginationPolicy >> affect: response within: aContext [

	self subclassResponsibility 
]

{ #category : #applying }
ResourcePaginationPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	self subclassResponsibility
]
