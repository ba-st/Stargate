"
I'm a simple model of a currency
"
Class {
	#name : 'StargateCurrency',
	#superclass : 'Object',
	#instVars : [
		'name',
		'symbol',
		'isoCode'
	],
	#category : 'Stargate-Examples-Currencies',
	#package : 'Stargate-Examples',
	#tag : 'Currencies'
}

{ #category : 'instance creation' }
StargateCurrency class >> named: aName symbol: aSymbol isoCode: anIsoCode [

	^ self new initializeNamed: aName symbol: aSymbol isoCode: anIsoCode
]

{ #category : 'initialization' }
StargateCurrency >> initializeNamed: aName symbol: aSymbol isoCode: anIsoCode [

	name := aName.
	symbol := aSymbol.
	isoCode := anIsoCode
]

{ #category : 'accessing' }
StargateCurrency >> isoCode [

	^ isoCode
]

{ #category : 'accessing' }
StargateCurrency >> name [

	^ name
]

{ #category : 'accessing' }
StargateCurrency >> symbol [

	^ symbol
]
