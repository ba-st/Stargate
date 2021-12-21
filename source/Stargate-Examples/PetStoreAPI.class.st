Class {
	#name : #PetStoreAPI,
	#superclass : #StargateAPISkeleton,
	#instVars : [
		'apiOptional'
	],
	#category : #'Stargate-Examples'
}

{ #category : #private }
PetStoreAPI class >> applicationBaselineName [

	^ #BaselineOfStargate
]

{ #category : #accessing }
PetStoreAPI class >> commandName [

	^ 'pet-store'
]

{ #category : #accessing }
PetStoreAPI class >> description [

	^'A RESTful API for Pet stores'
]

{ #category : #accessing }
PetStoreAPI class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #private }
PetStoreAPI class >> sectionsForStargateConfiguration [

	^ #( 'Pet Store' ) , super sectionsForStargateConfiguration
]

{ #category : #'private - activation' }
PetStoreAPI >> basicStartWithin: context [

	apiOptional := Optional containing: (super basicStartWithin: context)
]

{ #category : #'private - accessing' }
PetStoreAPI >> controllersToInstall [

	^ Array with: PetsRESTfulController new with: PetOrdersRESTfulController new
]

{ #category : #initialization }
PetStoreAPI >> initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider [

	super initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider.
	apiOptional := Optional unused
]

{ #category : #'private - accessing' }
PetStoreAPI >> stargateConfiguration [

	^self configuration petStore stargate
]

{ #category : #'private - activation' }
PetStoreAPI >> stop [

	apiOptional withContentDo: [ :api | api stop ]
]
