Class {
	#name : #IsUUID,
	#superclass : #IsObject,
	#category : #'Stargate-REST-API'
}

{ #category : #'type constraint' }
IsUUID class >> matchesTo: aString [

	^ aString isString and: [ '[\da-z]+' asRegex matches: aString ]
]

{ #category : #'type constraint' }
IsUUID class >> parseString: aString [

	^ UUID fromString36: aString
]
