Class {
	#name : #RouteSpecificationTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
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
		assert: route resourceLocation equals: '/pets'
]
