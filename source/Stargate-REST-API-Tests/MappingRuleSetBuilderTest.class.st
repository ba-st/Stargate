Class {
	#name : #MappingRuleSetBuilderTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'accessing - media types' }
MappingRuleSetBuilderTest >> applicationJsonVersion1dot0dot0MediaType [

	^ 'application/json;version=1.0.0' asZnMimeType 
]

{ #category : #'accessing - media types' }
MappingRuleSetBuilderTest >> applicationJsonVersion1dot0dot1MediaType [

	^ 'application/json;version=1.0.1' asZnMimeType 
]

{ #category : #accessing }
MappingRuleSetBuilderTest >> keyRepresentingTriggers [

	^ #triggers
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testAddingDecodingRuleWithAlreadyRegisteredMediaTypeGivesConflictingObjectFound [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addRuleToDecode: ZnMimeType textPlain
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	self
		should: [ builder
				addRuleToDecode: ZnMimeType textPlain
				to: self keyRepresentingTriggers
				using: self triggerJsonDecoderVersion1dot0dot0 ]
		raise: ConflictingObjectFound
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals:
					'Decoding rule for this media type already registered' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testAddingEncodingRuleWithAlreadyRegisteredMediaTypeGivesConflictingObjectFound [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addRuleToEncode: self keyRepresentingTriggers
		to: ZnMimeType textPlain
		using: self triggerJsonEncoderVersion1dot0dot0.

	self
		should: [ builder
				addRuleToEncode: #triggers
				to: ZnMimeType textPlain
				using: self triggerJsonEncoderVersion1dot0dot0 ]
		raise: ConflictingObjectFound
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals: 'Encoding rule for this media type already registered' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingGivesInstanceCreationFailedBecauseDefaultDecodingRuleIsMissing [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addRuleToDecode: self applicationJsonVersion1dot0dot0MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals: 'You must provide exactly one default decoding rule for each object type' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingGivesInstanceCreationFailedBecauseDefaultEncodingRuleIsMissing [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0MediaType
		using: self triggerJsonDecoderVersion1dot0dot0.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals: 'You must provide exactly one default encoding rule for each object type' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingGivesInstanceCreationFailedBecauseMoreThanOneDefaultDEncodingRuleWasConfigured [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0MediaType
		using: self triggerJsonEncoderVersion1dot0dot0.

	builder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot1MediaType
		using: self triggerJsonEncoderVersion1dot0dot1.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals: 'You must provide exactly one default encoding rule for each object type' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingGivesInstanceCreationFailedBecauseMoreThanOneDefaultDecodingRuleWasConfigured [

	| builder |

	builder := MappingRuleSetBuilder new.

	builder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot0MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	builder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	self
		should: [ builder build ]
		raise: InstanceCreationFailed
		withExceptionDo: [ :signal | 
			self
				assert: signal messageText
				equals: 'You must provide exactly one default decoding rule for each object type' ]
]

{ #category : #tests }
MappingRuleSetBuilderTest >> testBuildingSuccessfully [

	| mappingRuleSetBuilder |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0MediaType
		using: self triggerJsonDecoderVersion1dot0dot0.

	self shouldnt: [ mappingRuleSetBuilder build ] raise: Error
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetBuilderTest >> triggerJsonDecoderVersion1dot0dot0 [

	^ #triggerJsonDecoderVersion1dot0dot0
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetBuilderTest >> triggerJsonDecoderVersion1dot0dot1 [

	^ #triggerJsonDecoderVersion1dot0dot1
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetBuilderTest >> triggerJsonEncoderVersion1dot0dot0 [

	^ #triggerJsonEncoderVersion1dot0dot0
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetBuilderTest >> triggerJsonEncoderVersion1dot0dot1 [

	^ #triggerJsonEncoderVersion1dot0dot1
]
