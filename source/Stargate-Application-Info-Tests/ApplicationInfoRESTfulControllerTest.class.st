"
An ApplicationInfoRESTfulControllerTest is a test class for testing the behavior of ApplicationInfoRESTfulController
"
Class {
	#name : #ApplicationInfoRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#category : #'Stargate-Application-Info-Tests'
}

{ #category : #'private - support' }
ApplicationInfoRESTfulControllerTest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationInfoPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #'info-providers' put: ApplicationInformationProvider allProviderNames;
				yourself );
		yourself
]

{ #category : #running }
ApplicationInfoRESTfulControllerTest >> setUpResourceController [

	resourceController := ApplicationInfoRESTfulController
		over: ( ApplicationInfoPlugin configuredBy: self operationsConfiguration )
		configuredBy: self operationsConfiguration
]

{ #category : #tests }
ApplicationInfoRESTfulControllerTest >> testGetInfoInJson [

	| response |

	response := resourceController
		getApplicationInfoBasedOn:
			( self
				requestToGET: self resourceUrl
				accepting: resourceController operationalApplicationInfoVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController operationalApplicationInfoVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :info | 
			self
				assert: info os general platform notEmpty;
				assert: info pharo image version notEmpty;
				assert: info pharo vm version notEmpty
			]
]
