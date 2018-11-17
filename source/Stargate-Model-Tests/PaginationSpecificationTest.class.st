"
I'm a Test Case for PaginationSpec
"
Class {
	#name : #PaginationSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Pagination'
}

{ #category : #tests }
PaginationSpecificationTest >> testAccessing [

	| spec |

	spec := PaginationSpecification startingAt: 1 limitedTo: 5.

	self
		assert: spec start equals: 1;
		assert: spec limit equals: 5;
		assert: spec end equals: 5
]

{ #category : #tests }
PaginationSpecificationTest >> testPrintString [

	self
		assert: (PaginationSpecification startingAt: 1 limitedTo: 5) printString
		equals:
			'start=1
limit=5'
]
