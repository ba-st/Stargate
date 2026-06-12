"
A JWTBearerAuthorizationFilterTest is a test class for testing the behavior of JWTBearerAuthorizationFilter
"
Class {
	#name : 'JWTBearerAuthorizationFilterTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Auth',
	#package : 'Stargate-Model-Tests',
	#tag : 'Auth'
}

{ #category : 'private' }
JWTBearerAuthorizationFilterTest >> assertResponseFor: request isForbiddenAfterApplying: filter [

  self
    should: [ filter teaEvalActionOnRequest: request ]
    raise: HTTPForbidden
    withExceptionDo: [ :error |
        self
          assert: error code equals: 403;
          assert: ( error challenge beginsWith: filter authChallenge )
      ]
]

{ #category : 'private' }
JWTBearerAuthorizationFilterTest >> newFilter [

  ^ JWTBearerAuthorizationFilter on: self realm
]

{ #category : 'private' }
JWTBearerAuthorizationFilterTest >> realm [

	^ 'api.example.com'
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testAuthChallenge [

  self assert: self newFilter authChallenge equals: 'Bearer realm=api.example.com'
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testEmptyPermissions [

  | filter httpRequest requestContext |
  filter := self newFilter.

  httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
                   setAuthorization:
                     ( 'Bearer <1s>' expandMacrosWith: ( self tokenWithPermissions: #(  ) ) );
                   yourself.


  self shouldnt: [ filter teaEvalActionOnRequest: httpRequest ] raise: HTTPForbidden.
  requestContext := HttpRequestContext new.
  filter evaluateActionOnRequest: httpRequest within: requestContext.

  self deny: ( requestContext includesPermission: 'read:xxx' )
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testInvalidToken [

  | filter httpRequest |
  filter := self newFilter.

  httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
                   setAuthorization: 'Bearer xxx';
                   yourself.

  self assertResponseFor: httpRequest isForbiddenAfterApplying: filter
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testInvalidType [

	| filter httpRequest |

	filter := self newFilter.
	httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
		setAuthorization: 'Basic admin:xxx';
		yourself.
	self assertResponseFor: httpRequest isForbiddenAfterApplying: filter
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testMissingHeader [

  | request |
  request := TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ).
  self assertResponseFor: request isForbiddenAfterApplying: self newFilter
]

{ #category : 'tests' }
JWTBearerAuthorizationFilterTest >> testWithPermissions [

  | filter httpRequest requestContext |
  filter := self newFilter.

  httpRequest := ( TeaRequest fromZnRequest: ( ZnRequest get: '/secure' asUrl ) )
                   setAuthorization:
                     ( 'Bearer <1s>' expandMacrosWith:
                           ( self tokenWithPermissions: #( 'read:xxx' 'write:xxx' ) ) );
                   yourself.


  self shouldnt: [ filter teaEvalActionOnRequest: httpRequest ] raise: HTTPForbidden.
  requestContext := HttpRequestContext new.
  filter evaluateActionOnRequest: httpRequest within: requestContext.

  self
    assert: ( requestContext includesPermission: 'read:xxx' );
    assert: ( requestContext includesPermission: 'write:xxx' );
    deny: ( requestContext includesPermission: 'read:yyy' )
]

{ #category : 'private' }
JWTBearerAuthorizationFilterTest >> tokenWithPermissions: permissions [

  | jws |
  jws := JsonWebSignature new
           algorithmName: 'none';
           payload: ( JWTClaimsSet new
                 permissions: permissions;
                 yourself ).

  ^ jws compactSerialized
]
