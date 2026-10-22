Class {
	#name : 'SecurityFilter',
	#superclass : 'Object',
	#category : 'Stargate-Model-Auth',
	#package : 'Stargate-Model',
	#tag : 'Auth'
}

{ #category : 'testing' }
SecurityFilter class >> isAbstract [

  <ignoreForCoverage>
  ^ self = SecurityFilter
]

{ #category : 'configuring headers' }
SecurityFilter >> affectResponse: aResponse [
  "The response depends on the credentials I read, so a cache has to key it by them"

  [ aResponse addToVary: 'Authorization' ] unless:
    ( aResponse varyHeaderNames includes: 'Authorization' )
]

{ #category : 'private' }
SecurityFilter >> checkCredentials: authorization for: httpRequest within: requestContext [

	self subclassResponsibility
]

{ #category : 'evaluating' }
SecurityFilter >> evaluateActionOnRequest: httpRequest within: requestContext [

  | authorization |
  authorization := httpRequest headers
                     at: 'Authorization'
                     ifAbsent: [ self signalMissingAuthorizationHeader ].
  self checkCredentials: authorization for: httpRequest within: requestContext
]

{ #category : 'private' }
SecurityFilter >> signalMissingAuthorizationHeader [

  ^ self subclassResponsibility
]

{ #category : 'evaluating' }
SecurityFilter >> teaEvalActionOnRequest: httpRequest [

	self evaluateActionOnRequest: httpRequest within: HttpRequestContext new
]

{ #category : 'evaluating' }
SecurityFilter >> teaEvalActionOnRequest: httpRequest response: httpResponse [

  self affectResponse: httpResponse
]
