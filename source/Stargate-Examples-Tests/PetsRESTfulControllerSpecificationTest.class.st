"
Test case for PetsRESTfulControllerSpecification
"
Class {
	#name : #PetsRESTfulControllerSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Examples-Tests'
}

{ #category : #tests }
PetsRESTfulControllerSpecificationTest >> testTemplate [

	| spec |

	spec := PetsRESTfulControllerSpecification new.

	self assert: spec idTemplate equals: '/pets/<identifier:IsInteger>'
]
