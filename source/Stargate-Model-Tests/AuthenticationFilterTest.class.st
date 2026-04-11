"
I'm an abstract test case for authentication filters
"
Class {
	#name : 'AuthenticationFilterTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Auth',
	#package : 'Stargate-Model-Tests',
	#tag : 'Auth'
}

{ #category : 'testing' }
AuthenticationFilterTest class >> isAbstract [

	^ self name = #AuthenticationFilterTest
]

{ #category : 'private' }
AuthenticationFilterTest >> assertResponseFor: request isUnauthorizedAfterApplying: filter [

  self
    should: [ filter teaEvalActionOnRequest: request ]
    raise: HTTPUnauthorized
    withExceptionDo: [ :error |
        self
          assert: error code equals: 401;
          assert: ( error challenge beginsWith: filter authChallenge )
      ]
]

{ #category : 'private' }
AuthenticationFilterTest >> newFilter [

	"Return a new instance of the authentication filter under test"

	^ self subclassResponsibility
]

{ #category : 'tests' }
AuthenticationFilterTest >> testAuthChallenge [

	self subclassResponsibility
]

{ #category : 'tests' }
AuthenticationFilterTest >> testBasedOnConfiguration [

	self subclassResponsibility
]

{ #category : 'tests' }
AuthenticationFilterTest >> testInvalidCredentials [

	self subclassResponsibility
]

{ #category : 'tests' }
AuthenticationFilterTest >> testInvalidType [

	self subclassResponsibility
]

{ #category : 'tests' }
AuthenticationFilterTest >> testMissingHeader [

	| request |

	request := TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ).

	self assertResponseFor: request isUnauthorizedAfterApplying: self newFilter
]

{ #category : 'tests' }
AuthenticationFilterTest >> testValidCredentials [

	self subclassResponsibility
]
