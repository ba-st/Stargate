"
I'm the test case for the Application Information API
"
Class {
	#name : #ApplicationInfoPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Info-Tests'
}

{ #category : #running }
ApplicationInfoPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationInfoPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #'info-providers' put: #('application');
				yourself );
		yourself
]

{ #category : #running }
ApplicationInfoPluginAPITest >> requiredPermissions [

	^ #('read:application-info')
]

{ #category : #running }
ApplicationInfoPluginAPITest >> setUp [

	super setUp.
	BasicApplicationInformationProvider new
		applicationNamed: 'Test App'
		describedBy: 'An application for testing purposes'
		version: '8.9'
]

{ #category : #tests }
ApplicationInfoPluginAPITest >> testDisablePlugin [

	self assert: ( api isEnabled: ApplicationInfoPlugin ).

	api disable: ApplicationInfoPlugin endpoint.

	self deny: ( api isEnabled: ApplicationInfoPlugin ).

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationInfoPlugin endpoint asUrl;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #tests }
ApplicationInfoPluginAPITest >> testGetInfoWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationInfoPlugin endpoint asUrl;
		setAccept: ZnMimeType applicationJson;
		get;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: 'application/vnd.stargate.operational-application-info+json;version=1.0.0' asMediaType;
		withJsonFromContentsIn: response
			do: [ :info | 
			self
				assert: info application version equals: '8.9';
				assert: info application name equals: 'Test App';
				assert: info application description equals: 'An application for testing purposes'
			]
]
