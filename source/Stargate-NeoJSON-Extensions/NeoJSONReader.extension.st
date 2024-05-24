Extension { #name : 'NeoJSONReader' }

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> for: smalltalkClass createInstanceUsing: block [

	| mapping |

	mapping := self instanceCreationMappingFor: smalltalkClass.
	block value: mapping.
	^ mapping
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> for: schemaName strictDo: block [

	| mapping |

	mapping := self strictMappingFor: schemaName.
	block value: mapping.
	^ mapping
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> instanceCreationMappingFor: smalltalkClass [

	^ self mappings at: smalltalkClass ifAbsentPut: [
		  InstanceCreationMapping new
			  subjectClass: smalltalkClass;
			  yourself
		  ]
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> strictMappingFor: smalltalkClass [

	^ self mappings at: smalltalkClass ifAbsentPut: [
		  NeoJSONStrictObjectMapping new
			  subjectClass: smalltalkClass;
			  yourself
		  ]
]
