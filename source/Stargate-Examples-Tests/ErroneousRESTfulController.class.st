Class {
	#name : 'ErroneousRESTfulController',
	#superclass : 'SingleResourceRESTfulController',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-Examples-Tests-Server-Errors',
	#package : 'Stargate-Examples-Tests',
	#tag : 'Server-Errors'
}

{ #category : 'routes' }
ErroneousRESTfulController >> declareGetConflictingRoute [

  ^ RouteSpecification
      handling: #GET
      at: self identifierTemplate , '/conflict'
      evaluating: [ :httpRequest :requestContext | HTTPClientError conflict signal: 'Client error' ]
]

{ #category : 'routes' }
ErroneousRESTfulController >> declareGetErroneousRoute [

	^ RouteSpecification
		  handling: #GET
		  at: self identifierTemplate
		  evaluating: [ :httpRequest :requestContext | Error signal: 'Server error' ]
]

{ #category : 'routes' }
ErroneousRESTfulController >> declareGetObjectNotFoundRoute [

  ^ RouteSpecification
      handling: #GET
      at: self identifierTemplate , '/not-found'
      evaluating: [ :httpRequest :requestContext | ObjectNotFound signal: 'Not found' ]
]

{ #category : 'initialization' }
ErroneousRESTfulController >> initialize [

	super initialize.
	requestHandler := RESTfulRequestHandlerBuilder new
		                  handling: 'errors'
		                  extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		                  whenResponding: ZnMimeType applicationJson
		                  encodeToJsonApplying: [ :resource :requestContext :writer |  ];
		                  createEntityTagHashingEncodedResource;
		                  build
]

{ #category : 'private' }
ErroneousRESTfulController >> requestHandler [

	^ requestHandler 
]

{ #category : 'private' }
ErroneousRESTfulController >> typeIdConstraint [

	^ IsObject
]
