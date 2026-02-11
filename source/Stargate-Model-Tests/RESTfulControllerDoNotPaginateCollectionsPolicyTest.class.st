"
Unit Test
"
Class {
	#name : 'RESTfulControllerDoNotPaginateCollectionsPolicyTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Pagination',
	#package : 'Stargate-Model-Tests',
	#tag : 'Pagination'
}

{ #category : 'private' }
RESTfulControllerDoNotPaginateCollectionsPolicyTest >> evaluateCollectionQuery: aBlockClosure basedOn: httpRequest within: requestContext [

	^ aBlockClosure value
]

{ #category : 'tests' }
RESTfulControllerDoNotPaginateCollectionsPolicyTest >> testBehavior [

  | policy context controls response |
  context := HttpRequestContext new.
  controls := #(  ).
  policy := RESTfulControllerDoNotPaginateCollectionsPolicy for: self.
  self assert: ( policy addPaginationControlsTo: controls within: context ) isEmpty.

  response := ZnResponse noContent.
  policy affect: response within: context.
  self assert: response links isEmpty.

  self assert: ( policy evaluateQuery: [ 23 ] basedOn: ZnRequest new within: context ) equals: 23
]
