Class {
	#name : #HttpRequestContext,
	#superclass : #Object,
	#instVars : [
		'knownObjects'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #accessing }
HttpRequestContext >> hold: anObject under: aConcept [

	knownObjects at: aConcept put: anObject
]

{ #category : #initialization }
HttpRequestContext >> initialize [

	super initialize.
	knownObjects := Dictionary new
]

{ #category : #accessing }
HttpRequestContext >> objectUnder: aConcept ifNone: aBlock [

	^ knownObjects at: aConcept ifAbsent: aBlock
]
