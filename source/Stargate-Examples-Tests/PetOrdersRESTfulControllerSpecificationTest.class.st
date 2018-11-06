"
Test Case for PetOrdersRESTfulControllerSpecification
"
Class {
	#name : #PetOrdersRESTfulControllerSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Examples-Tests'
}

{ #category : #tests }
PetOrdersRESTfulControllerSpecificationTest >> testTemplate [

	| spec |

	spec := PetOrdersRESTfulControllerSpecification new.

	self
		assert: spec idTemplate equals: '/orders/<identifier:IsInteger>';
		assert: spec cancelTemplate equals: '/orders/<identifier:IsInteger>/cancel';
		assert: spec completeTemplate equals: '/orders/<identifier:IsInteger>/complete'
]
