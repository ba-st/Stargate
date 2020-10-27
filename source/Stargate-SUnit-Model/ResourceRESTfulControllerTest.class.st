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
ResourceRESTfulControllerTest >> assertCachingDirectivesFor: response with: aString [

	self assert: response cachingDirectives equals: aString
]

{ #category : #'private - asserting' }
ResourceRESTfulControllerTest >> assertExpiresHeaderFor: response with: aDuration [

	| oneMinuteBeforeFourHours fourHoursInTheFuture expiresString |

	expiresString := response headers at: #expires ifAbsent: [ self fail ].
	
	"This is just in case the test runs at a time when the minute has changed"
	oneMinuteBeforeFourHours := ZnUtils httpDate: DateAndTime now + aDuration - 1 minute.
	fourHoursInTheFuture := ZnUtils httpDate: DateAndTime now + aDuration.

	self
		assert: ( expiresString = oneMinuteBeforeFourHours or: [ expiresString = fourHoursInTheFuture ] )
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

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> withJsonFromItemsIn: httpResponse do: aBlock [

	self withJsonFromContentsIn: httpResponse do: [:json | aBlock value: json items]
]
