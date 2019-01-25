Class {
	#name : #CrossOriginResourceSharingAfterFilter,
	#superclass : #Object,
	#instVars : [
		'allowedOrigins'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingAfterFilter class >> allowing: origins [

	^ self new initializeAllowing: origins
]

{ #category : #initialization }
CrossOriginResourceSharingAfterFilter >> initializeAllowing: origins [

	allowedOrigins := origins
]

{ #category : #'tea action' }
CrossOriginResourceSharingAfterFilter >> teaEvalActionOnRequest: request response: response [

	| requestOrigin requestOriginUrl |

	requestOrigin := request headers at: 'Origin'.
	requestOriginUrl := requestOrigin asUrl.
	
	allowedOrigins
		detect: [ :origin | origin = requestOriginUrl ]
		ifFound: [ :allowedOrigin | 
			response headers
				at: 'Access-Control-Allow-Origin' put: requestOrigin;
				at: 'Vary' put: 'Origin' ].
			
	^ response
]
