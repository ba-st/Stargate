"
Test case
"
Class {
	#name : 'RouteSpecificationTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Routing',
	#package : 'Stargate-Model-Tests',
	#tag : 'Routing'
}

{ #category : 'private' }
RouteSpecificationTest >> evaluate: aRouteSpecification authenticatedOn: anHttpRequest [

  anHttpRequest setBasicAuthenticationUsername: 'admin' password: 'secret'.
  ^ ( aRouteSpecification authenticatedBy:
        ( ZnAuthenticationFilter username: 'admin' password: 'secret' ) ) handler
      value: anHttpRequest
      value: HttpRequestContext new
]

{ #category : 'tests' }
RouteSpecificationTest >> testAuthenticatedRouteNamesAuthorizationInVaryOnce [

  | route response |
  route := RouteSpecification
             handling: #GET
             at: '/pets'
             evaluating: [ :httpRequest :requestContext |
                 ZnResponse noContent
                   addToVary: 'Authorization';
                   yourself
               ].

  response := self
                evaluate: route
                authenticatedOn: ( TeaRequest fromZnRequest: ( ZnRequest get: '/pets' asUrl ) ).

  self assert: response varyHeaderNames equals: #( 'Authorization' )
]

{ #category : 'tests' }
RouteSpecificationTest >> testAuthenticatedRouteVariesOnAuthorization [

  | route response |
  route := RouteSpecification
             handling: #GET
             at: '/pets'
             evaluating: [ :httpRequest :requestContext | ZnResponse ok: ( ZnEntity text: 'pets' ) ].

  response := self
                evaluate: route
                authenticatedOn: ( TeaRequest fromZnRequest: ( ZnRequest get: '/pets' asUrl ) ).

  self
    assert: response isSuccess;
    assert: response varyHeaderNames equals: #( 'Authorization' )
]

{ #category : 'tests' }
RouteSpecificationTest >> testInstanceCreationAndAccessing [

	| route |

	route := RouteSpecification
		handling: #GET
		at: '/pets'
		evaluating: [ :httpRequest :requestContext | self fail ].

	self
		assert: route httpMethod equals: #GET;
		assert: route urlTemplate equals: '/pets'
]
