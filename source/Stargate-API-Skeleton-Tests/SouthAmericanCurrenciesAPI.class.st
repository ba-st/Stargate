Class {
	#name : #SouthAmericanCurrenciesAPI,
	#superclass : #StargateAPISkeleton,
	#category : #'Stargate-API-Skeleton-Tests'
}

{ #category : #private }
SouthAmericanCurrenciesAPI class >> applicationBaselineName [

	^ #BaselineOfStargate
]

{ #category : #accessing }
SouthAmericanCurrenciesAPI class >> commandName [

	^ 'currencies'
]

{ #category : #accessing }
SouthAmericanCurrenciesAPI class >> description [

	^'API for South american currencies'
]

{ #category : #initialization }
SouthAmericanCurrenciesAPI class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #'private - accessing' }
SouthAmericanCurrenciesAPI >> controllersToInstall [

	^ Array with: SouthAmericanCurrenciesRESTfulController new
]
