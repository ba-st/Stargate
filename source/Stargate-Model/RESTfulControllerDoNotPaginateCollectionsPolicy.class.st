"
I'm the policy indicating a RESTful controller to not support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTfulControllerDoNotPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'requestHandler'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTfulControllerDoNotPaginateCollectionsPolicy class >> for: aRequestHandler [

	^ self new initializeFor: aRequestHandler
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: requestContext [

	^ mediaControls 
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> affect: response within: requestContext [
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: httpRequest [

	^ requestHandler evaluateCollectionQuery: aQueryEvaluationBlock
]

{ #category : #initialization }
RESTfulControllerDoNotPaginateCollectionsPolicy >> initializeFor: aRequestHandler [

	requestHandler := aRequestHandler 
]
