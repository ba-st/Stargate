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

	^ RouteSpecification
		handling: #POST
		at: '/tests'
		evaluating: [ :httpRequest :requestContext | self fail ] 
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> getTestsRoute [

	^ RouteSpecification
		handling: #GET
		at: '/tests'
		evaluating: [ :httpRequest :requestContext | self fail ]
]

{ #category : #accessing }
ReflectiveRoutesConfiguratorTest >> routes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'Route' to: self) value
]

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testConfiguringCrossOriginResourceSharingAwareRoutes [

	| teapot |

	teapot := Teapot on.

	(ReflectiveRoutesConfigurator appliedTo: teapot) addRoutesOf: self.

	self assert: teapot routes size equals: 2
]

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testConfiguringPetsControllerRoutes [

	| teapot |

	teapot := Teapot on.

	( ReflectiveRoutesConfigurator appliedTo: teapot ) addRoutesOf: PetsRESTfulController new.

	self assert: teapot routes size equals: 5
]
