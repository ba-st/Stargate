"
I'm testing an API configured to answer client errors with its own handler.
"
Class {
	#name : 'ClientErrorHandlerAPITest',
	#superclass : 'HTTPBasedRESTfulAPITest',
	#category : 'Stargate-Examples-Tests-Server-Errors',
	#package : 'Stargate-Examples-Tests',
	#tag : 'Server-Errors'
}

{ #category : 'running' }
ClientErrorHandlerAPITest >> apiConfiguration [

  ^ super apiConfiguration , { #clientErrorHandler -> [ :clientError :request |
        ( ZnResponse statusCode: clientError code )
          entity: ( ZnEntity with: '{"status":409}' ofType: 'application/problem+json' asMediaType );
          yourself
      ] }
]

{ #category : 'private' }
ClientErrorHandlerAPITest >> controllersToInstall [

  ^ { ErroneousRESTfulController new }
]

{ #category : 'tests' }
ClientErrorHandlerAPITest >> testCORSAppliedToClientErrorResponses [

  | response |
  api allowCrossOriginSharingApplying: [ :cors | cors allowAnyOrigin ].

  response := self newClient
                url: self baseUrl / 'errors' / '1' / 'conflict' asUrl;
                headerAt: 'Origin' put: self baseUrl printString;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 409;
    assert: ( response headers at: 'Access-Control-Allow-Origin' ) equals: '*'
]

{ #category : 'tests' }
ClientErrorHandlerAPITest >> testClientErrorsAreAnsweredByTheConfiguredHandler [

  | response |
  response := self newClient
                url: self baseUrl / 'errors' / '1' / 'conflict' asUrl;
                enforceHttpSuccess: false;
                get;
                response.

  self
    assert: response code equals: 409;
    assert: response contentType equals: 'application/problem+json' asMediaType;
    assert: response contents equals: '{"status":409}'
]
