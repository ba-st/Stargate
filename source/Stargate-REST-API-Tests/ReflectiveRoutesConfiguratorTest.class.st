Class {
	#name : #ReflectiveRoutesConfiguratorTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #tests }
ReflectiveRoutesConfiguratorTest >> testAddingRoutes [

	| teapot webService |

	teapot := Teapot on.

	webService := PetsRESTfulWebService new.

	(ReflectiveRoutesConfigurator appliedTo: teapot) 
		addRoutesOf: webService.

	self assert: teapot routes size equals: 5
]
