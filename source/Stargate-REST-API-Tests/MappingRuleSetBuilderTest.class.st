Class {
	#name : #MappingRuleSetBuilderTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #accessing }
MappingRuleSetBuilderTest >> applicationJsonVersion1dot0dot0 [

	^ ZnMimeType fromString: 'application/json;version=1.0.0'
]

{ #category : #accessing }
MappingRuleSetBuilderTest >> applicationJsonVersion1dot0dot1 [

	^ ZnMimeType fromString: 'application/json;version=1.0.1'
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testAddingDecoderForAlreadyAddedMimeTypeFails [

	| mappingRegistry |

	mappingRegistry := MappingRuleSetBuilder new.

	mappingRegistry
		addRuleToDecode: ZnMimeType textPlain
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	self
		should: [ mappingRegistry
				addRuleToDecode: ZnMimeType textPlain
				to: #triggers
				using: self triggerJsonDecoderVersion1dot0dot0 ]
		raise: ConflictingObjectFound
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testAddingEncoderForAlreadyAddedMimeTypeFails [

	| mappingRegistry |

	mappingRegistry := MappingRuleSetBuilder new.

	mappingRegistry
		addRuleToEncode: #triggers
		to: ZnMimeType textPlain
		using: self triggerJsonEncoderVersion1dot0dot0.

	self
		should: [ mappingRegistry
				addRuleToEncode: #triggers
				to: ZnMimeType textPlain
				using: self triggerJsonEncoderVersion1dot0dot0 ]
		raise: ConflictingObjectFound
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuilding [

	| mappingRuleSetBuilder |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1
		to: #trigger
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #trigger
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToEncode: #trigger
		to: self applicationJsonVersion1dot0dot0
		using: self triggerJsonDecoderVersion1dot0dot0.

	self shouldnt: [ mappingRuleSetBuilder build ] raise: Error
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingFailsBecauseMustProvideDefault [

	| mappingRuleSetBuilder |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	self should: [ mappingRuleSetBuilder build ] raise: AssertionFailed
]

{ #category : #accessing }
MappingRuleSetBuilderTest >> triggerJsonDecoderVersion1dot0dot0 [

	^ #triggerJsonDecoderVersion1dot0dot0
]

{ #category : #accessing }
MappingRuleSetBuilderTest >> triggerJsonDecoderVersion1dot0dot1 [

	^ #triggerJsonDecoderVersion1dot0dot1
]

{ #category : #accessing }
MappingRuleSetBuilderTest >> triggerJsonEncoderVersion1dot0dot0 [

	^ #triggerJsonEncoderVersion1dot0dot0
]
