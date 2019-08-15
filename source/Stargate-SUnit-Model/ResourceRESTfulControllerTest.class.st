"
I'm an abstract Test Case providing facililties to test RESTfulControllers
"
Class {
	#name : #ResourceRESTfulControllerTest,
	#superclass : #TestCase,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-SUnit-Model'
}

{ #category : #testing }
ResourceRESTfulControllerTest class >> isAbstract [

	^ self name = #ResourceRESTfulControllerTest
]

{ #category : #'private - asserting' }
ResourceRESTfulControllerTest >> assertUrl: aStringOrUrl equals: anotherStringOrUrl [

	self assert: aStringOrUrl asZnUrl equals: anotherStringOrUrl asZnUrl
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> baseUrl [

	^ self subclassResponsibility
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> newHttpRequestContext [

	^ HttpRequestContext new
]

{ #category : #running }
ResourceRESTfulControllerTest >> setUp [

	super setUp.
	self setUpResourceController.
	resourceController serverUrl: self baseUrl asZnUrl
]

{ #category : #running }
ResourceRESTfulControllerTest >> setUpResourceController [

	self subclassResponsibility
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
