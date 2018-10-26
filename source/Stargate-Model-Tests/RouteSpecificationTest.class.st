"
Test case
"
Class {
	#name : #RouteSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Routing'
}

{ #category : #tests }
RouteSpecificationTest >> testInstanceCreationAndAccessing [

	| route |

	route := RouteSpecification 
		handling: #GET 
		at: '/pets' 
		sending: #getPetsBasedOn:within:.

	self
		assert: route httpMethod equals: #GET;
		assert: route urlTemplate equals: '/pets'
]
