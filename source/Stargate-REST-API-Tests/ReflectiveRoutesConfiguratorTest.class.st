Class {
	#name : #ReflectiveRoutesConfiguratorTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> createTestRoute [

	^ (RouteSpecification handling: #POST at: '/tests' sending: #createTestBasedOn:) asCorsAware
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> getTestsRoute [

	^ RouteSpecification handling: #GET at: '/tests' sending: #getTestsBasedOn:
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> specification [
	
	^ self
]

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testAddingRoutes [

	| teapot |

	teapot := Teapot on.

	(ReflectiveRoutesConfigurator appliedTo: teapot) addRoutesOf: self.

	self assert: teapot routes size equals: 3
]
