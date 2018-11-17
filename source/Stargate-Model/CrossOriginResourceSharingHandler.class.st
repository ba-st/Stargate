Class {
	#name : #CrossOriginResourceSharingHandler,
	#superclass : #Object,
	#instVars : [
		'httpMethods'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingHandler class >> allowing: anHttpMethodsCollection [

	^ self new initializeAllowing: anHttpMethodsCollection
]

{ #category : #'private - accessing' }
CrossOriginResourceSharingHandler >> commaSeparatedHttpMethods [

	^ (CollectionFormatter separatingWith: ', ') format: httpMethods
]

{ #category : #initialization }
CrossOriginResourceSharingHandler >> initializeAllowing: anHttpMethodsCollection [

	httpMethods := anHttpMethodsCollection
]

{ #category : #evaluating }
CrossOriginResourceSharingHandler >> teaEvalActionOnRequest: aRequest [

	| response |

	response := ZnResponse noContent.

	response headers
		at: 'Access-Control-Allow-Headers'
			put: 'Access-Control-Allow-Origin, Content-Type, Accept';
		at: 'Access-Control-Allow-Methods'
			put: self commaSeparatedHttpMethods;
		at: 'Access-Control-Max-Age' put: '86400'.

	^ response
]
