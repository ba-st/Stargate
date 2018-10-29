"
Test Case for PetOrdersRESTfulWebServiceSpecification
"
Class {
	#name : #PetOrdersRESTfulWebServiceSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Examples-Tests'
}

{ #category : #tests }
PetOrdersRESTfulWebServiceSpecificationTest >> testTemplate [

	| spec |

	spec := PetOrdersRESTfulWebServiceSpecification new.

	self
		assert: spec idTemplate equals: '/orders/<identifier:IsInteger>';
		assert: spec cancelTemplate equals: '/orders/<identifier:IsInteger>/cancel';
		assert: spec completeTemplate equals: '/orders/<identifier:IsInteger>/complete'
]
