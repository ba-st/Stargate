Extension { #name : 'NeoJSONReader' }

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> for: schemaName createInstanceUsing: block [

	| mapping |

	mapping := self validCompleteInstanceMappingFor: schemaName.
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
NeoJSONReader >> strictMappingFor: smalltalkClass [

	^ self mappings at: smalltalkClass ifAbsentPut: [
		  NeoJSONStrictObjectMapping new
			  subjectClass: smalltalkClass;
			  yourself
		  ]
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONReader >> validCompleteInstanceMappingFor: smalltalkClass [

	^ self mappings at: smalltalkClass ifAbsentPut: [
		  ValidCompleteInstanceMapping new
			  subjectClass: smalltalkClass;
			  yourself
		  ]
]
