"
I'm a reflective builder for a mapping rule set (see MappingRuleSet).

I'm being used to build a mapping rule set reflectively. I expect web service specification declare its rules on messages that follow the pattern #add*MappingIn:
"
Class {
	#name : #ReflectiveMappingRuleSetBuilder,
	#superclass : #Object,
	#instVars : [
		'specification'
	],
	#category : #'Stargate-Deprecated-V3'
}

{ #category : #deprecation }
ReflectiveMappingRuleSetBuilder class >> isDeprecated [

	^ true
]
