"
I'm the policy indicating a RESTful controller to not support pagination of collections related to the controlled resource.
"
Class {
	#name : #RESTfulControllerDoNotPaginateCollectionsPolicy,
	#superclass : #RESTfulControllerPaginationPolicy,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Pagination'
}

{ #category : #'instance creation' }
RESTfulControllerDoNotPaginateCollectionsPolicy class >> for: aResourceController [

	^ self new initializeFor: aResourceController
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> addPaginationControlsTo: mediaControls within: aContext [

	^ mediaControls 
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> affect: response within: aContext [
]

{ #category : #applying }
RESTfulControllerDoNotPaginateCollectionsPolicy >> evaluateQuery: aQueryEvaluationBlock basedOn: anHttpRequest [

	^ resourceController evaluateQuery: aQueryEvaluationBlock
]

{ #category : #initialization }
RESTfulControllerDoNotPaginateCollectionsPolicy >> initializeFor: aResourceController [

	resourceController := aResourceController 
]
