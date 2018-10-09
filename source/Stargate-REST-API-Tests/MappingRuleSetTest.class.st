Class {
	#name : #MappingRuleSetTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJson [
	
	^ ZnMimeType applicationJson 
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot0dot0 [

	^ ZnMimeType fromString: 'application/json; version=1.0.0'
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot0dot1 [

	^ ZnMimeType fromString: 'application/json; version=1.0.1'
]

{ #category : #'accessing - media types' }
MappingRuleSetTest >> applicationJsonVersion1dot1dot0 [

	^ ZnMimeType fromString: 'application/json; version=1.1.0'
]

{ #category : #accessing }
MappingRuleSetTest >> keyRepresentingTriggers [

	^ #triggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleByAnyMediaTypeGivesDefault [

	| mappingRuleSetBuilder mappingRuleSet decodingRule |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet ruleToDecode: ZnMimeType any to: #triggers.
	self
		assert: decodingRule mediaType equals: self applicationJsonVersion1dot0dot1;
		assert: decodingRule objectType equals: #triggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleByMediaTypeSpecificVersion [

	| mappingRuleSetBuilder mappingRuleSet decodingRule |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet
		ruleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers.
	self
		assert: decodingRule mediaType equals: self applicationJsonVersion1dot0dot0;
		assert: decodingRule objectType equals: #triggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleByMediaTypeWithoutVersionGivesDefault [

	| mappingRuleSetBuilder mappingRuleSet decodingRule |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	decodingRule := mappingRuleSet ruleToDecode: self applicationJson to: #triggers.
	self
		assert: decodingRule mediaType equals: self applicationJsonVersion1dot0dot1;
		assert: decodingRule objectType equals: #triggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleByNotRegisteredMediaTypeGivesObjectNotFound [

	| mappingRuleSetBuilder mappingRuleSet |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self textPlain
		to: #triggers
		using: self triggerTextDecoder.

	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToDecode: self applicationJsonVersion1dot0dot0
				to: #triggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingDecodingRuleByNotRegisteredSpecificVersionGivesObjectNotFound [

	| mappingRuleSetBuilder mappingRuleSet |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToDecode: self applicationJsonVersion1dot0dot0
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToDecode: self applicationJsonVersion1dot0dot1
		to: #triggers
		using: self triggerJsonDecoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	self
		should: [ mappingRuleSet
				ruleToDecode: self applicationJsonVersion1dot1dot0
				to: #triggers ]
		raise: MappingNotFound
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleByAnyMediaTypeGivesDefault [

	| mappingRuleSetBuilder mappingRuleSet encodingRule |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0
		using: self triggerJsonEncoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot1
		using: self triggerJsonEncoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	encodingRule := mappingRuleSet ruleToEncode: self keyRepresentingTriggers to: ZnMimeType any.
	
	self
		assert: encodingRule mediaType equals: self applicationJsonVersion1dot0dot1;
		assert: encodingRule objectType equals: self keyRepresentingTriggers
]

{ #category : #tests }
MappingRuleSetTest >> testQueryingEncodingRuleByMediaTypeSpecificVersion [

	| mappingRuleSetBuilder mappingRuleSet encodingRule |

	mappingRuleSetBuilder := MappingRuleSetBuilder new.

	mappingRuleSetBuilder
		addRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0
		using: self triggerJsonEncoderVersion1dot0dot0.

	mappingRuleSetBuilder
		addDefaultRuleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot1
		using: self triggerJsonEncoderVersion1dot0dot1.

	mappingRuleSet := mappingRuleSetBuilder build.

	encodingRule := mappingRuleSet
		ruleToEncode: self keyRepresentingTriggers
		to: self applicationJsonVersion1dot0dot0.
	
	self
		assert: encodingRule mediaType equals: self applicationJsonVersion1dot0dot0;
		assert: encodingRule objectType equals: self keyRepresentingTriggers
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
