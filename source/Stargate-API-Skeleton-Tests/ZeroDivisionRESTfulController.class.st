"
I'm a RESTful controller whose only route signals a ZeroDivide, used to check the error handlers an application adds.
"
Class {
	#name : 'ZeroDivisionRESTfulController',
	#superclass : 'SingleResourceRESTfulController',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'routes' }
ZeroDivisionRESTfulController >> declareDivideRoute [

  ^ RouteSpecification
      handling: #GET
      at: self endpoint
      evaluating: [ :httpRequest :requestContext | 1 / 0 ]
]

{ #category : 'initialization' }
ZeroDivisionRESTfulController >> initialize [

  super initialize.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'divisions';
                      createEntityTagHashingEncodedResource;
                      build
]

{ #category : 'private' }
ZeroDivisionRESTfulController >> requestHandler [

  ^ requestHandler
]

{ #category : 'private' }
ZeroDivisionRESTfulController >> typeIdConstraint [

  ^ IsObject
]
