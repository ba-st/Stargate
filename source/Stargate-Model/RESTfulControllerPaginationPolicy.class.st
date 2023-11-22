"
I'm the policy used to control pagination in a RESTfulController
"
Class {
	#name : 'RESTfulControllerPaginationPolicy',
	#superclass : 'Object',
	#category : 'Stargate-Model-Pagination',
	#package : 'Stargate-Model',
	#tag : 'Pagination'
}

{ #category : 'applying' }
RESTfulControllerPaginationPolicy >> addPaginationControlsTo: mediaControls within: httpRequest [

	^ self subclassResponsibility 
]

{ #category : 'applying' }
RESTfulControllerPaginationPolicy >> affect: response within: requestContext [

	self subclassResponsibility 
]

{ #category : 'applying' }
RESTfulControllerPaginationPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: httpRequest [

	self subclassResponsibility
]
