"
A HTTPBasedRESTfulAPITest is a test class for testing the behavior of HTTPBasedRESTfulAPI
"
Class {
	#name : #HTTPBasedRESTfulAPITest,
	#superclass : #TestCase,
	#instVars : [
		'api'
	],
	#category : #'Stargate-SUnit-Model'
}

{ #category : #testing }
HTTPBasedRESTfulAPITest class >> isAbstract [

	^ self name = #HTTPBasedRESTfulAPITest
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> algorithmName [

	^ JWAHMACSHA256 parameterValue
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> baseUrl [

	^ 'http://localhost' asUrl port: self port
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> checkPortAvailability [

	[ | socket |

	socket := ZnNetworkingUtils serverSocketOn: self port.
	socket close
	]
		on: Error
		do: [ :error | self fail: ( 'Port <1p> is not available' expandMacrosWith: self port ) ]
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> claimSet [

	^ JWTClaimsSet new
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> newClient [

	^ ZnClient new
		beOneShot;
		enforceHttpSuccess: true;
		yourself
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> newJWTAuthorizedClient [

	^ self newJWTAuthorizedClientClaiming: self claimSet
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> newJWTAuthorizedClientClaiming: aClaimSet [

	| client jws |

	jws := JsonWebSignature new.
	jws algorithmName: self algorithmName.
	jws payload: aClaimSet.
	jws key: self secret.

	client := self newClient.
	client request setAuthorization: ( 'Bearer <1s>' expandMacrosWith: jws compactSerialized ).
	^ client
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: self algorithmName;
		at: #authSecret put: self secret;
		yourself
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> port [

	^ self subclassResponsibility
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> secret [

	^ 'secret'
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> setUp [

	super setUp.
	self setUpAPI.
	api
		install;
		start
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> setUpAPI [

	self checkPortAvailability.
	api := HTTPBasedRESTfulAPI
		configuredBy:
			{ #port -> self port.
			 #serverUrl -> self baseUrl.
			 #operations -> self operationsConfiguration }
		installing: self controllersToInstall.

	api on: Error addErrorHandler: [ :error :request | self fail ]
]

{ #category : #running }
HTTPBasedRESTfulAPITest >> tearDown [

	api ifNotNil: [ api stop ].
	api := nil.
	super tearDown
]

{ #category : #private }
HTTPBasedRESTfulAPITest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
