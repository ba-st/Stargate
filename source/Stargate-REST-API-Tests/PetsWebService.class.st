Class {
	#name : #PetsWebService,
	#superclass : #RESTfulWebService,
	#instVars : [
		'pets'
	],
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'instance creation' }
PetsWebService class >> managing: aPetSet [ 
	
	^ self new initializeManaging: aPetSet 
]

{ #category : #initialization }
PetsWebService >> initializeManaging: aPetSet [

	pets := aPetSet. 
]

{ #category : #accessing }
PetsWebService >> specification [

	^ PetsWebServiceSpecification new
]
