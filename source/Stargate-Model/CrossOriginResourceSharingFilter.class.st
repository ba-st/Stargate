"
I'm a filter used to add CORS support to a HTTPBasedRESTfulAPI instance
"
Class {
	#name : 'CrossOriginResourceSharingFilter',
	#superclass : 'Object',
	#instVars : [
		'filter'
	],
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'private - instance creation' }
CrossOriginResourceSharingFilter class >> applying: aFilter [

	^ self new initializeApplying: aFilter 
]

{ #category : 'instance creation' }
CrossOriginResourceSharingFilter class >> handleActualRequestByEvaluating: aHandler [

	^ self
		applying: [ :teapotServer | 
			teapotServer
				after: '/*' -> aHandler;
				when: [ :request | request headers includesKey: 'Origin' ]
			]
]

{ #category : 'instance creation' }
CrossOriginResourceSharingFilter class >> handlePreflightByEvaluating: aHandler [

	^ self applying: [ :teapotServer | 
		  teapotServer
			  before: '/*' -> aHandler;
			  when: [ :request | self isForPreflight: request ]
		  ]
]

{ #category : 'testing' }
CrossOriginResourceSharingFilter class >> isForPreflight: request [

	^ ( request headers includesKey: 'Origin' ) and: [ request method = #OPTIONS ]
]

{ #category : 'applying' }
CrossOriginResourceSharingFilter >> applyOn: aTeapot [

	filter value: aTeapot 
]

{ #category : 'initialization' }
CrossOriginResourceSharingFilter >> initializeApplying: aBlock [

	filter := aBlock 
]
