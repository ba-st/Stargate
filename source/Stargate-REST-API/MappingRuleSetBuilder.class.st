Class {
	#name : #MappingRuleSetBuilder,
	#superclass : #Object,
	#instVars : [
		'decodingRules',
		'encodingRules'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #configuring }
MappingRuleSetBuilder >> addDefaultRuleToDecode: aMediaType to: aKeyRepresentingObjectType using: aReader [

	| decodingRule |

	decodingRule := self
		ruleToDecode: aMediaType
		to: aKeyRepresentingObjectType
		using: aReader.
		
	decodingRule beDefault.
	decodingRules add: decodingRule
]

{ #category : #configuring }
MappingRuleSetBuilder >> addDefaultRuleToEncode: aKeyRepresentingObjectType to: aMediaType using: aWriter [

	| encodingRule |

	encodingRule := self
		ruleToEncode: aMediaType
		to: aKeyRepresentingObjectType
		using: aWriter.
		
	encodingRule beDefault.
	encodingRules add: encodingRule
]

{ #category : #configuring }
MappingRuleSetBuilder >> addRuleToDecode: aMediaType to: aKeyRepresentingObjectType using: aReader [

	| decodingRule |

	decodingRule := self
		ruleToDecode: aMediaType
		to: aKeyRepresentingObjectType
		using: aReader.

	decodingRules add: decodingRule
]

{ #category : #configuring }
MappingRuleSetBuilder >> addRuleToEncode: aKeyRepreseningObjectType to: aMediaType using: aWriter [

	| encodingRule |

	encodingRule := self
		ruleToEncode: aMediaType
		to: aKeyRepreseningObjectType
		using: aWriter.
		
	encodingRules add: encodingRule
]

{ #category : #'private - preconditions' }
MappingRuleSetBuilder >> assertDefaultRuleAreConfigured [

	AssertionCheckerBuilder new
		checking: [ :asserter | 
			asserter
				enforce: [ self
						thereIsOnlyOneDefaultRuleForEachObjectTypeOn: decodingRules ]
					because: 'You must provide exactly one default decoding rule for each object type';
				enforce: [ self
						thereIsOnlyOneDefaultRuleForEachObjectTypeOn: encodingRules ]
					because: 'You must provide exactly one default encoding rule for each object type' ];
		raising: InstanceCreationFailed;
		buildAndCheck
]

{ #category : #'private - preconditions' }
MappingRuleSetBuilder >> assertThereIsntConfiguredRuleToDecode: aMediaType to: anObjectType [

	AssertionCheckerBuilder new
		raising: ConflictingObjectFound;
		checking: [ :asserter | 
			asserter
				enforce: [ decodingRules
						noneSatisfy: [ :rule | rule mediaType = aMediaType and: [ rule objectType = anObjectType ] ] ]
				because: 'Decoding rule for this media type already registered' ];
		buildAndCheck
]

{ #category : #'private - preconditions' }
MappingRuleSetBuilder >> assertThereIsntConfiguredRuleToEncode: anObjectType to: aMediaType [

	AssertionCheckerBuilder new
		raising: ConflictingObjectFound;
		checking: [ :asserter | 
			asserter
				enforce: [ encodingRules
						noneSatisfy: [ :rule | rule mediaType = aMediaType and: [ rule objectType = anObjectType ] ] ]
				because: 'Encoding rule for this media type already registered' ];
		buildAndCheck
]

{ #category : #building }
MappingRuleSetBuilder >> build [

	self assertDefaultRuleAreConfigured.

	^ MappingRuleSet consistingOf: encodingRules and: decodingRules
]

{ #category : #initialization }
MappingRuleSetBuilder >> initialize [

	encodingRules := OrderedCollection new.
	decodingRules := OrderedCollection new
]

{ #category : #'private - configuring' }
MappingRuleSetBuilder >> ruleToDecode: aMediaType to: aKeyRepresentingObjectType using: aReader [

	self
		assertThereIsntConfiguredRuleToDecode: aMediaType
		to: aKeyRepresentingObjectType.

	^ DecodingMappingRule 
		decoding: aMediaType
		to: aKeyRepresentingObjectType
		using: aReader
]

{ #category : #'private - configuring' }
MappingRuleSetBuilder >> ruleToEncode: aMediaType to: aKeyRepresentingObjectType using: aWriter [

	self
		assertThereIsntConfiguredRuleToEncode: aKeyRepresentingObjectType
		to: aMediaType.
		
	^ EncodingMappingRule 
		encoding: aKeyRepresentingObjectType
		to: aMediaType
		using: aWriter
]

{ #category : #'private - preconditions' }
MappingRuleSetBuilder >> thereIsOnlyOneDefaultRuleForEachObjectTypeOn: aMappingRuleCollection [

	^ (aMappingRuleCollection groupedBy: #objectType) values
		allSatisfy: [ :groupedMappingRules | 
			(groupedMappingRules
				count: [ :mappingRule | mappingRule isDefault ]) = 1 ]
]
