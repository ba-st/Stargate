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
