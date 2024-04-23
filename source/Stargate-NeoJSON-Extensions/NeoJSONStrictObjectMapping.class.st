"
I am NeoJSONStrictObjectMapping, I'm equivalent to NeoJSONObjectMapping but more strict.
I will fail on reading properties of an object if some of the mapped properties are missing in the incoming JSON.

"
Class {
	#name : 'NeoJSONStrictObjectMapping',
	#superclass : 'NeoJSONObjectMapping',
	#category : 'Stargate-NeoJSON-Extensions',
	#package : 'Stargate-NeoJSON-Extensions'
}

{ #category : 'private' }
NeoJSONStrictObjectMapping >> errorDescriptionForMissing: propertyNames [

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: 'Missing required keys';
			  space;
			  nextPut: $(.
		  propertyNames
			  do: [ :propertyName |
				  stream
					  nextPut: $#;
					  nextPutAll: propertyName
				  ]
			  separatedBy: [
				  stream
					  nextPut: $,;
					  space
				  ].
		  stream nextPut: $)
		  ]
]

{ #category : 'parsing' }
NeoJSONStrictObjectMapping >> readFrom: jsonReader [

	| anObject propertyNames |

	anObject := subjectClass new.
	allowNil ifTrue: [
		jsonReader parseConstantDo: [ :value |
			^ value ifNotNil: [ jsonReader error: 'Unexpected boolean constant' ] ]
		].
	propertyNames := properties collect: [ :each | each propertyName ].
	jsonReader parseMapKeysDo: [ :key |
		( self propertyNamed: key ifAbsent: [ nil ] )
			ifNil: [ "read, skip & ignore value" jsonReader next ]
			ifNotNil: [ :mapping |
				propertyNames remove: key asSymbol.
				mapping readObject: anObject from: jsonReader
				]
		].
	propertyNames ifNotEmpty: [ jsonReader error: ( self errorDescriptionForMissing: propertyNames ) ].
	( anObject respondsTo: #assertIsValid ) then: [ anObject assertIsValid ].
	^ anObject
]
