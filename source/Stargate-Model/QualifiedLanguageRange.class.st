"
I'm a language range including a quality parameter as used in Accept-Language headers
"
Class {
	#name : 'QualifiedLanguageRange',
	#superclass : 'Object',
	#instVars : [
		'languangeRange',
		'quality'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
QualifiedLanguageRange class >> fromString: aString [

	^ ( aString substrings: ';' )
		  ifEmpty: [
		  InstanceCreationFailed signal: 'Cannot create a qualified language range with an empty string' ]
		  ifNotEmpty: [ :tokens |
			  | quality languageRange |

			  languageRange := LanguageRange fromString: tokens first trimBoth.
			  quality := tokens withoutFirst
				             detect: [ :parameter | parameter beginsWith: 'q=' ]
				             ifFound: [ :qParameter |
					             ( qParameter withoutFirst: 2 )
						             ifEmpty: [ InstanceCreationFailed signal: 'Invalid quality parameter value' ]
						             ifNotEmpty: [ :qValue | qValue asNumber ]
					             ]
				             ifNone: [ 1.0 ].
			  self qualifying: languageRange with: quality
			  ]
]

{ #category : 'instance creation' }
QualifiedLanguageRange class >> qualifying: aLanguageRange with: aQualityFactor [

	^ self new initializeQualifying: aLanguageRange with: aQualityFactor
]

{ #category : 'initialization' }
QualifiedLanguageRange >> initializeQualifying: aLanguageRange with: aQualityFactor [

	languangeRange := aLanguageRange.
	quality := aQualityFactor
]

{ #category : 'accessing' }
QualifiedLanguageRange >> quality [

	^ quality
]

{ #category : 'accessing' }
QualifiedLanguageRange >> range [

	^ languangeRange
]
