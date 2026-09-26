"
I'm testing extensions to classes in the Hyperspace project
"
Class {
	#name : 'HyperspaceExtensionsTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Extensions',
	#package : 'Stargate-Model-Tests',
	#tag : 'Extensions'
}

{ #category : 'tests' }
HyperspaceExtensionsTest >> testBadRequestAsJSON [

	| error json |

	error := HTTPClientError badRequest messageText: 'Ouch!'.
	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: error ).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 400
]

{ #category : 'tests' }
HyperspaceExtensionsTest >> testForbiddenAffectResponse [

  | error response |
  error := HTTPForbidden messageText: 'Forbidden' with: 'Bearer realm="api.example.com"'.
  response := ZnResponse statusCode: 403.

  error affectResponse: response.

  self assert: ( response headers at: 'WWW-Authenticate' ) equals: 'Bearer realm="api.example.com"'
]

{ #category : 'tests' }
HyperspaceExtensionsTest >> testForbiddenAffectResponseBecauseScopeIsInsufficient [

  | error response |
  error := ( HTTPForbidden messageText: 'Missing permissions' with: 'Bearer realm="api.example.com"' )
             errorCode: 'insufficient_scope';
             requiredPermissions: #( 'read:pets' 'update:pets' );
             yourself.
  response := ZnResponse statusCode: 403.

  error affectResponse: response.

  self
    assert: ( response headers at: 'WWW-Authenticate' )
    equals:
    'Bearer realm="api.example.com", error="insufficient_scope", error_description="Missing permissions", scope="read:pets update:pets"'
]

{ #category : 'tests' }
HyperspaceExtensionsTest >> testNotAcceptableAsJSON [

	| error json |

	error := HTTPNotAcceptable
		messageText: 'Ouch!'
		accepting: {'application/xml' asMediaType}
		inAnyOf: ( #('en-us' 'es-ar') collect: #asLanguageTag ).
	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: error ).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 406;
		assert: json allowedMediaTypes size equals: 1;
		assert: json allowedMediaTypes first equals: 'application/xml';
		assert: json allowedLanguageTags size equals: 2;
		assert: json allowedLanguageTags first equals: 'en-US';
		assert: json allowedLanguageTags last equals: 'es-AR'
]

{ #category : 'tests' }
HyperspaceExtensionsTest >> testUnauthorizedAffectResponse [

  | error response |
  error := HTTPUnauthorized messageText: 'Unauthorized' with: 'Bearer realm="api.example.com"'.
  response := ZnResponse statusCode: 401.

  error affectResponse: response.

  self assert: ( response headers at: 'WWW-Authenticate' ) equals: 'Bearer realm="api.example.com"'
]

{ #category : 'tests' }
HyperspaceExtensionsTest >> testUnauthorizedAffectResponseBecauseTokenIsInvalid [

  | error response |
  error := ( HTTPUnauthorized messageText: 'Invalid token' with: 'Bearer realm="api.example.com"' )
             errorCode: 'invalid_token';
             yourself.
  response := ZnResponse statusCode: 401.

  error affectResponse: response.

  self
    assert: ( response headers at: 'WWW-Authenticate' )
    equals:
    'Bearer realm="api.example.com", error="invalid_token", error_description="Invalid token"'
]
