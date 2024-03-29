"
A HTTPBasedRESTfulAPITest is a test class for testing the behavior of HTTPBasedRESTfulAPI
"
Class {
	#name : 'HTTPBasedRESTfulAPITest',
	#superclass : 'TestCase',
	#instVars : [
		'api',
		'port'
	],
	#category : 'Stargate-SUnit-Model',
	#package : 'Stargate-SUnit-Model'
}

{ #category : 'testing' }
HTTPBasedRESTfulAPITest class >> isAbstract [

	^ self name = #HTTPBasedRESTfulAPITest
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> algorithmName [

	^ 'HS256'
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> baseUrl [

	^ 'http://localhost' asUrl port: self port
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> claimSet [

	^ JWTClaimsSet new
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> globalErrorHandler [

	^ [ :error :request | self fail ]
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> newClient [

	^ ZnClient new
		beOneShot;
		enforceHttpSuccess: true;
		yourself
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> newJWTAuthorizedClient [

	^ self newJWTAuthorizedClientClaiming: self claimSet
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> newJWTAuthorizedClientClaiming: aClaimSet [

	| client jws |

	jws := JsonWebSignature new.
	jws algorithmName: self algorithmName.
	jws payload: aClaimSet.
	jws symmetricKey: self secret.

	client := self newClient.
	client request setAuthorization: ( 'Bearer <1s>' expandMacrosWith: jws compactSerialized ).
	^ client
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: self algorithmName;
		at: #authSecret put: self secret;
		yourself
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> port [

	^ port
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> secret [

	^ 'secret'
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> setUp [

	super setUp.
	port :=  self freeListeningTCPPort.
	self setUpAPI.
	api
		install;
		start
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> setUpAPI [

	api := HTTPBasedRESTfulAPI
		       configuredBy: {
				       ( #port -> self port ).
				       ( #serverUrl -> self baseUrl ).
				       ( #operations -> self operationsConfiguration ) }
		       installing: self controllersToInstall.

	api on: Error addErrorHandler: self globalErrorHandler
]

{ #category : 'running' }
HTTPBasedRESTfulAPITest >> tearDown [

	api ifNotNil: [ api stop ].
	api := nil.
	super tearDown
]

{ #category : 'private' }
HTTPBasedRESTfulAPITest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
