"
I'm the policy used to control pagination in a RESTfulController
"
Class {
	#name : #RESTfulControllerPaginationPolicy,
	#superclass : #Object,
	#category : #'Stargate-Model-Pagination'
}

{ #category : #applying }
RESTfulControllerPaginationPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ self subclassResponsibility 
]

{ #category : #applying }
RESTfulControllerPaginationPolicy >> affect: response within: aContext [

	self subclassResponsibility 
]

{ #category : #applying }
RESTfulControllerPaginationPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	self subclassResponsibility
]
