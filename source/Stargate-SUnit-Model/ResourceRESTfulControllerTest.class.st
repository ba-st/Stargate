"
I'm an abstract Test Case providing facililties to test RESTfulControllers
"
Class {
	#name : 'ResourceRESTfulControllerTest',
	#superclass : 'TestCase',
	#instVars : [
		'resourceController'
	],
	#category : 'Stargate-SUnit-Model',
	#package : 'Stargate-SUnit-Model'
}

{ #category : 'testing' }
ResourceRESTfulControllerTest class >> isAbstract [

	^ self name = #ResourceRESTfulControllerTest
]

{ #category : 'private - asserting' }
ResourceRESTfulControllerTest >> assertCachingDirectivesFor: response with: aString [

	self assert: response cachingDirectives equals: aString
]

{ #category : 'private - asserting' }
ResourceRESTfulControllerTest >> assertExpiresHeaderFor: response with: aDuration [

  | expiresString expectedExpiration |
  expiresString := response headers at: #expires ifAbsent: [ self fail ].
  expectedExpiration := DateAndTime now + aDuration.
  "The header is precise to the second, and the response was affected up to a minute ago"
  self assert: ( ( 0 to: 60 ) anySatisfy: [ :elapsedSeconds |
          expiresString = ( ZnUtils httpDate: expectedExpiration - elapsedSeconds seconds ) ] )
]

{ #category : 'private - support' }
ResourceRESTfulControllerTest >> baseUrl [

	^ self subclassResponsibility
]

{ #category : 'private - support' }
ResourceRESTfulControllerTest >> newHttpRequestContext [

	^ HttpRequestContext new
]

{ #category : 'running' }
ResourceRESTfulControllerTest >> setUp [

	super setUp.
	self setUpResourceController.
	resourceController serverUrl: self baseUrl asZnUrl
]

{ #category : 'running' }
ResourceRESTfulControllerTest >> setUpResourceController [

	self subclassResponsibility
]

{ #category : 'private - support' }
ResourceRESTfulControllerTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]

{ #category : 'private - support' }
ResourceRESTfulControllerTest >> withJsonFromItemsIn: httpResponse do: aBlock [

	self withJsonFromContentsIn: httpResponse do: [:json | aBlock value: json items]
]
