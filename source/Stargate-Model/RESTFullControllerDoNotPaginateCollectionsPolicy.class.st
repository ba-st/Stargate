"
I'm the policy indicating a RESTful controller to not support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTFullControllerDoNotPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTFullControllerDoNotPaginateCollectionsPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController
]

{ #category : #applying }
RESTFullControllerDoNotPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls 
]

{ #category : #applying }
RESTFullControllerDoNotPaginateCollectionsPolicy >> affect: response within: aContext [
]

{ #category : #applying }
RESTFullControllerDoNotPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: aQueryEvaluationBlock
]

{ #category : #initialization }
RESTFullControllerDoNotPaginateCollectionsPolicy >> initializeFor: aResourceController [

	resourceController := aResourceController 
]
