"
I'm a test case for MappingRuleSet
"
Class {
	#name : #MappingRuleSetTest,
	#superclass : #TestCase,
	#instVars : [
		'mappingRuleSetBuilder'
	],
	#category : #'Stargate-Model-Tests-Mapping'
}

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersDecodingRuleForApplicationJsonVersion1dot0dot0 [

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot0
]

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersDefaultDecodingRuleForApplicationJsonVersion1dot0dot1 [

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1MediaType
		to: self keyRepresentingTriggers
		using: self triggerJsonDecoderVersion1dot0dot1
]

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersDefaultDecodingRuleForTextPlain [

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self textPlain
		to: self keyRepresentingTriggers
		using: self triggerTextDecoder
]

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersDefaultEncodingRuleForApplicationJsonVersion1dot0dot1 [

	mappingRuleSetBuilder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot1MediaType
		using: self triggerJsonEncoderVersion1dot0dot1
]

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersDefaultEncodingRuleForTextPlain [

	mappingRuleSetBuilder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self textPlain
		using: self triggerTextEncoder
]

{ #category : #'tests support' }
MappingRuleSetTest >> addTriggersEncodingRuleForApplicationJsonVersion1dot0dot0 [

	mappingRuleSetBuilder
		addRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0MediaType
		using: self triggerJsonEncoderVersion1dot0dot0
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonMediaType [
	
	^ ZnMimeType applicationJson 
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot0dot0MediaType [

	^ 'application/json; version=1.0.0' asMediaType
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot0dot1MediaType [

	^ 'application/json; version=1.0.1' asMediaType 
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot1dot0MediaType [

	^ 'application/json; version=1.1.0' asMediaType
]

{ #category : #accessing }
MappingRuleSetTest >> keyRepresentingTriggers [

	^ #triggers
]

{ #category : #running }
MappingRuleSetTest >> setUp [

		mappingRuleSetBuilder := MappingRuleSetBuilder new.
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleUsingAnyMediaTypeGivesDefault [

	| mappingRuleSet decodingRule |

	self
		addTriggersDecodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultDecodingRuleForApplicationJsonVersion1dot0dot1.
	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet
		ruleToDecode: ZnMimeType any
		to: self keyRepresentingTriggers.

	self
		assert: decodingRule mediaType
			equals: self applicationJsonVersion1dot0dot1MediaType;
		assert: decodingRule objectType
			equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleUsingNotRegisteredMediaTypeGivesObjectNotFound [

	| mappingRuleSet |

	self addTriggersDefaultDecodingRuleForTextPlain.
	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToDecode: self applicationJsonVersion1dot0dot0MediaType
				to: self keyRepresentingTriggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleUsingNotRegisteredVersionOfMediaTypeGivesObjectNotFound [

	| mappingRuleSet |

	self
		addTriggersDecodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultDecodingRuleForApplicationJsonVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToDecode: self applicationJsonVersion1dot1dot0MediaType
				to: self keyRepresentingTriggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleUsingNotVersionedMediaTypeGivesDefault [

	| mappingRuleSet decodingRule |

	self
		addTriggersDecodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultDecodingRuleForApplicationJsonVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet
		ruleToDecode: self applicationJsonMediaType
		to: self keyRepresentingTriggers.

	self
		assert: decodingRule mediaType
			equals: self applicationJsonVersion1dot0dot1MediaType;
		assert: decodingRule objectType
			equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleUsingVersionedMediaType [

	| mappingRuleSet decodingRule |

	self
		addTriggersDecodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultDecodingRuleForApplicationJsonVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet
		ruleToDecode: self applicationJsonVersion1dot0dot0MediaType
		to: self keyRepresentingTriggers.

	self
		assert: decodingRule mediaType equals: self applicationJsonVersion1dot0dot0MediaType;
		assert: decodingRule objectType equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleUsingAnyMediaTypeGivesDefault [

	| mappingRuleSet encodingRule |

	self
		addTriggersEncodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultEncodingRuleForApplicationJsonVersion1dot0dot1.
		
	mappingRuleSet := mappingRuleSetBuilder build.

	encodingRule := mappingRuleSet
		ruleToEncode: self keyRepresentingTriggers
		to: ZnMimeType any.

	self
		assert: encodingRule mediaType
			equals: self applicationJsonVersion1dot0dot1MediaType;
		assert: encodingRule objectType
			equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleUsingNotRegisteredMediaTypeGivesObjectNotFound [

	| mappingRuleSet |

	self addTriggersDefaultEncodingRuleForTextPlain.
	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToEncode: self applicationJsonVersion1dot0dot0MediaType
				to: self keyRepresentingTriggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleUsingNotRegisteredVersionOfMediaTypeGivesObjectNotFound [

	| mappingRuleSet |

	self
		addTriggersEncodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultEncodingRuleForApplicationJsonVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToEncode: self applicationJsonVersion1dot1dot0MediaType
				to: self keyRepresentingTriggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleUsingNotVersionedMediaTypeGivesDefault [

	| mappingRuleSet encondingRule |

	self
		addTriggersEncodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultEncodingRuleForApplicationJsonVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	encondingRule := mappingRuleSet
		ruleToEncode: self keyRepresentingTriggers
		to: self applicationJsonMediaType.

	self
		assert: encondingRule mediaType
			equals: self applicationJsonVersion1dot0dot1MediaType;
		assert: encondingRule objectType
			equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleUsingVersionedMediaType [

	| mappingRuleSet encodingRule |

	self
		addTriggersEncodingRuleForApplicationJsonVersion1dot0dot0;
		addTriggersDefaultEncodingRuleForApplicationJsonVersion1dot0dot1.
		
	mappingRuleSet := mappingRuleSetBuilder build.

	encodingRule := mappingRuleSet
		ruleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0MediaType.

	self
		assert: encodingRule mediaType
			equals: self applicationJsonVersion1dot0dot0MediaType;
		assert: encodingRule objectType
			equals: self keyRepresentingTriggers
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> textPlain [

	^ ZnMimeType fromString: 'text/plain;charset=utf-8'
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerJsonDecoderVersion1dot0dot0 [

	^ #triggerJsonDecoderVersion1dot0dot0
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerJsonDecoderVersion1dot0dot1 [

	^ #triggerJsonDecoderVersion1dot0dot1
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerJsonEncoderVersion1dot0dot0 [
	
	^ #triggerJsonEncoderVersion1dot0dot0
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerJsonEncoderVersion1dot0dot1 [
	
	^ #triggerJsonEncoderVersion1dot0dot1
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerTextDecoder [

	^ #triggerTextDecoder
]

{ #category : #'accessing - enconders and decoders' }
MappingRuleSetTest >> triggerTextEncoder [

	^ #triggerTextEncoder
]
