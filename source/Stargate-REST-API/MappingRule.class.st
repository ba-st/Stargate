Class {
	#name : #MappingRule,
	#superclass : #Object,
	#instVars : [
		'isDefault',
		'mediaType',
		'objectType',
		'mapper'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'private - instance creation' }
MappingRule class >> between: anObjectType and: aMediaType using: aMapper [

	^ self new
		initializeBetween: anObjectType
		and: aMediaType
		using: aMapper
]

{ #category : #applying }
MappingRule >> applyOn: anObjectToEncode within: aContext [

	^ self subclassResponsibility 
]

{ #category : #configuring }
MappingRule >> beDefault [

	isDefault := true
]

{ #category : #initialization }
MappingRule >> initializeBetween: anObjectType and: aMediaType using: aMapper [ 

	mapper := aMapper.
	mediaType := aMediaType.
	objectType := anObjectType.
	
	isDefault := false
]

{ #category : #testing }
MappingRule >> isDefault [

	^ isDefault
]

{ #category : #accessing }
MappingRule >> mediaType [

	^ mediaType
]

{ #category : #accessing }
MappingRule >> objectType [

	^ objectType
]
