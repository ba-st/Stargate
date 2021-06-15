"
A QualifiedLanguageRangeTest is a test class for testing the behavior of QualifiedLanguageRange
"
Class {
	#name : #QualifiedLanguageRangeTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #tests }
QualifiedLanguageRangeTest >> testCantParseInvalidStrings [

	self
		should: [ QualifiedLanguageRange fromString: '' ]
			raise: InstanceCreationFailed
			withMessageText: 'Cannot create a qualified language range with an empty string';
		should: [ QualifiedLanguageRange fromString: 'en;q=' ] raise: Error;
		should: [ QualifiedLanguageRange fromString: 'en;q=A' ] raise: Error
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromString [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: 'en-US'.

	self
		assert: qualifiedRange quality equals: 1.0;
		assert: qualifiedRange range equals: ( LanguageRange fromString: 'en-US' )
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromStringAndExtraParameters [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: 'en-US;x=y'.

	self
		assert: qualifiedRange quality equals: 1.0;
		assert: qualifiedRange range equals: ( LanguageRange fromString: 'en-US' )
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromStringWithAny [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: '*'.

	self
		assert: qualifiedRange quality equals: 1.0;
		assert: qualifiedRange range equals: LanguageRange any
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromStringWithAnyQualifier [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: '*;q=0.2'.

	self
		assert: qualifiedRange quality equals: 0.2;
		assert: qualifiedRange range equals: LanguageRange any
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromStringWithQualifier [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: 'en-US;q=0.2'.

	self
		assert: qualifiedRange quality equals: 0.2;
		assert: qualifiedRange range equals: ( LanguageRange fromString: 'en-US' )
]

{ #category : #tests }
QualifiedLanguageRangeTest >> testFromStringWithQualifierAndExtraParameters [

	| qualifiedRange |

	qualifiedRange := QualifiedLanguageRange fromString: 'en-US;x=y;q=0.2'.

	self
		assert: qualifiedRange quality equals: 0.2;
		assert: qualifiedRange range equals: ( LanguageRange fromString: 'en-US' )
]
