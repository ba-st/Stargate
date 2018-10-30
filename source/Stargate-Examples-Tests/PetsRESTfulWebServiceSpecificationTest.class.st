"
Test case for PetsRESTfulWebServiceSpecification
"
Class {
	#name : #PetsRESTfulWebServiceSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Examples-Tests'
}

{ #category : #tests }
PetsRESTfulWebServiceSpecificationTest >> testTemplate [

	| spec |

	spec := PetsRESTfulWebServiceSpecification new.

	self assert: spec idTemplate equals: '/pets/<identifier:IsInteger>'
]
