"
Unit Test
"
Class {
	#name : #ResourceNotPaginatedPolicyTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Pagination'
}

{ #category : #private }
ResourceNotPaginatedPolicyTest >> evaluateQuery: aBlockClosure [

	^ aBlockClosure value
]

{ #category : #tests }
ResourceNotPaginatedPolicyTest >> testBehavior [

	| policy context controls response |

	context := HttpRequestContext new.
	controls := #().
	policy := ResourceNotPaginatedPolicy for: self.
	self assert: (policy addPaginationControlsTo: controls within: context) isEmpty.

	response := ZnResponse noContent.
	policy affect: response within: context.
	self assert: response links isEmpty.

	self assert: (policy evaluateQuery: [ 23 ] basedOn: ZnRequest new) equals: 23
]
