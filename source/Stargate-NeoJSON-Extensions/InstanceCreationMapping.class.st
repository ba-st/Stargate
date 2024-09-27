"
I am InstanceCreationMapping, I'm equivalent to NeoJSONObjectMapping but require an instance creation method to build instances.
I will fail on reading properties of an object if some of the mapped properties are missing in the incoming JSON.

"
Class {
	#name : 'InstanceCreationMapping',
	#superclass : 'NeoJSONObjectMapping',
	#instVars : [
		'instanceCreationSelector',
		'argumentNames',
		'defaultsByArgumentName'
	],
	#category : 'Stargate-NeoJSON-Extensions',
	#package : 'Stargate-NeoJSON-Extensions'
}

{ #category : 'mapping' }
InstanceCreationMapping >> argumentNamed: anArgumentName defaultingTo: aValue [

  defaultsByArgumentName at: anArgumentName put: aValue
]

{ #category : 'private' }
InstanceCreationMapping >> defaultFor: argumentName ifAbsent: aBlock [

  ^ defaultsByArgumentName at: argumentName ifAbsent: aBlock
]

{ #category : 'private' }
InstanceCreationMapping >> errorDescriptionForMissing: propertyNames [

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

{ #category : 'mapping' }
InstanceCreationMapping >> mapCreationSending: anInstanceCreationSelector withArguments: anArgumentCollection [

  instanceCreationSelector := anInstanceCreationSelector.
  argumentNames := anArgumentCollection.
  defaultsByArgumentName := Dictionary new
]

{ #category : 'mapping' }
InstanceCreationMapping >> mapProperty: aKey [

	^ self
		  mapProperty: aKey
		  getter: [ :object |  ]
		  setter: [ :arguments :value | arguments at: aKey put: value ]
]

{ #category : 'mapping' }
InstanceCreationMapping >> mapProperty: aKey as: aValueSchema [

	( self mapProperty: aKey ) valueSchema: aValueSchema
]

{ #category : 'parsing' }
InstanceCreationMapping >> readFrom: jsonReader [

  | argumentByName arguments missingArguments |
  argumentByName := Dictionary new.
  jsonReader parseMapKeysDo: [ :key |
      ( self propertyNamed: key ifAbsent: [ nil ] )
        ifNil: [ "read, skip & ignore value" jsonReader next ]
        ifNotNil: [ :mapping | mapping readObject: argumentByName from: jsonReader ]
    ].

  missingArguments := OrderedCollection new.
  arguments := argumentNames collect: [ :argumentName |
                   argumentByName
                     at: argumentName
                     ifAbsent: [
                       self
                         defaultFor: argumentName
                         ifAbsent: [ missingArguments add: argumentName ] ]
                 ].
  missingArguments ifNotEmpty: [
      jsonReader error: ( self errorDescriptionForMissing: missingArguments ) ].

  ^ subjectClass perform: instanceCreationSelector withArguments: arguments
]
