"
A RouteConfiguratorTest is a test class for testing the behavior of RouteConfigurator
"
Class {
	#name : #RouteConfiguratorTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Routing'
}

{ #category : #tests }
RouteConfiguratorTest >> testConfiguringPetsControllerRoutes [

	| configurator teapot |

	teapot := Teapot on.
	self assert: teapot routes isEmpty.
	
	configurator := RouteConfigurator
		configuring: teapot
		withRoutesDefinedOn: PetsRESTfulController new.
	configurator configure.

	self
		assert: teapot routes size equals: 5
]
