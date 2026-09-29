"
I'm a RESTful controller whose only route fails an assertion, used to check the error handlers an application adds.
"
Class {
	#name : 'FailingAssertionRESTfulController',
	#superclass : 'SingleResourceRESTfulController',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'routes' }
FailingAssertionRESTfulController >> declareFailAssertionRoute [

  ^ RouteSpecification
      handling: #GET
      at: self endpoint
      evaluating: [ :httpRequest :requestContext | AssertionFailed signal: 'The assertion failed' ]
]

{ #category : 'initialization' }
FailingAssertionRESTfulController >> initialize [

  super initialize.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'assertions';
                      createEntityTagHashingEncodedResource;
                      build
]

{ #category : 'private' }
FailingAssertionRESTfulController >> requestHandler [

  ^ requestHandler
]

{ #category : 'private' }
FailingAssertionRESTfulController >> typeIdConstraint [

  ^ IsObject
]
