"
A RouteConfiguratorTest is a test class for testing the behavior of RouteConfigurator
"
Class {
	#name : #RouteConfiguratorTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Routing'
}

{ #category : #'as yet unclassified' }
RouteConfiguratorTest >> routes [

	^ OrderedCollection new
		add:
			( RouteSpecification
				handling: #POST
				at: '/tests'
				evaluating: [ :httpRequest :requestContext | self fail ] ) asCorsAware;
		yourself
]

{ #category : #tests }
RouteConfiguratorTest >> testConfiguringCrossOriginResourceSharingAwareRoutes [

	| configurator teapot controller |

	teapot := Teapot on.
	self assert: teapot routes isEmpty.

	controller := self .
	configurator := RouteConfigurator configuring: teapot withRoutesDefinedOn: controller.
	configurator configure.

	self
		deny: teapot routes isEmpty;
		assert: teapot routes size equals: 2
]

{ #category : #tests }
RouteConfiguratorTest >> testConfiguringPetsControllerRoutes [

	| configurator teapot controller |

	teapot := Teapot on.
	self assert: teapot routes isEmpty.

	controller := PetsRESTfulController new.
	configurator := RouteConfigurator configuring: teapot withRoutesDefinedOn: controller.
	configurator configure.

	self
		deny: teapot routes isEmpty;
		assert: teapot routes size equals: 5
]
