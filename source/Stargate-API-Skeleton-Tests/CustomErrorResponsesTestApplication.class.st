"
I'm a testing application used to check that the responses to client and unexpected errors can be customized.
"
Class {
	#name : 'CustomErrorResponsesTestApplication',
	#superclass : 'StargateApplication',
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'accessing' }
CustomErrorResponsesTestApplication class >> commandName [

  ^ 'custom-error-responses-test'
]

{ #category : 'accessing' }
CustomErrorResponsesTestApplication class >> description [

  ^ 'A Test API answering errors with problem details'
]

{ #category : 'initialization' }
CustomErrorResponsesTestApplication class >> initialize [

  <ignoreForCoverage>
  self initializeVersion
]

{ #category : 'private' }
CustomErrorResponsesTestApplication class >> projectName [

  ^ 'Stargate'
]

{ #category : 'private - accessing' }
CustomErrorResponsesTestApplication >> apiConfiguration [

  ^ super apiConfiguration , { #clientErrorHandler -> [ :clientError :request |
        self problemDetailsWithStatus: clientError code titled: clientError messageText ] }
]

{ #category : 'configuring' }
CustomErrorResponsesTestApplication >> configureAPI: anAPI [

  anAPI on: AssertionFailed addErrorHandler: [ :assertionFailed :request |
      self problemDetailsWithStatus: 422 titled: assertionFailed messageText ]
]

{ #category : 'private - accessing' }
CustomErrorResponsesTestApplication >> controllersToInstall [

  ^ Array
      with: PetsRESTfulController new
      with: PetOrdersRESTfulController new
      with: FailingAssertionRESTfulController new
]

{ #category : 'private' }
CustomErrorResponsesTestApplication >> problemDetailsWithStatus: aStatusCode titled: aTitle [

  ^ ( ZnResponse statusCode: aStatusCode )
      entity: ( ZnEntity
            with: ( NeoJSONWriter toString: ( Dictionary new
                        at: #status put: aStatusCode;
                        at: #title put: aTitle;
                        yourself ) )
            ofType: 'application/problem+json' asMediaType );
      yourself
]

{ #category : 'error handling' }
CustomErrorResponsesTestApplication >> responseForUnexpectedError: anError request: aRequest [

  ^ self problemDetailsWithStatus: 500 titled: 'Internal Server Error'
]
