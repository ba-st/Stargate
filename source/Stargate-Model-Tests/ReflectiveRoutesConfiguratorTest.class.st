"
I'm a test case for ReflectiveRoutesConfigurator
"
Class {
	#name : #ReflectiveRoutesConfiguratorTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Routing'
}

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> createTestRoute [

	^ (RouteSpecification handling: #POST at: '/tests' sending: #createTestBasedOn:) asCorsAware
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> getTestsRoute [

	^ (RouteSpecification handling: #GET at: '/tests' sending: #getTestsBasedOn:) asCorsAware
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> specification [
	
	^ self
]

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testConfiguringCrossOriginResourceSharingAwareRoutes [

	| teapot |

	teapot := Teapot on.

	(ReflectiveRoutesConfigurator appliedTo: teapot) addRoutesOf: self.

	self assert: teapot routes size equals: 3
]

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testConfiguringPetsControllerRoutes [

	| teapot controller |

	teapot := Teapot on.

	controller := PetsRESTfulController new.

	( ReflectiveRoutesConfigurator appliedTo: teapot ) addRoutesOf: controller.

	self assert: teapot routes size equals: 5
]
