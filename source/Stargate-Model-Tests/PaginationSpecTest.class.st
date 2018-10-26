"
I'm a Test Case for PaginationSpec
"
Class {
	#name : #PaginationSpecTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Services'
}

{ #category : #tests }
PaginationSpecTest >> testAccessing [

	| spec |

	spec := PaginationSpec startingAt: 1 limitedTo: 5.

	self
		assert: spec start equals: 1;
		assert: spec limit equals: 5;
		assert: spec end equals: 5
]

{ #category : #tests }
PaginationSpecTest >> testPrintString [

	self
		assert: (PaginationSpec startingAt: 1 limitedTo: 5) printString
		equals:
			'start=1
limit=5'
]
