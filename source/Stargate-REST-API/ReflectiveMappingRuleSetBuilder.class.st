Class {
	#name : #ReflectiveMappingRuleSetBuilder,
	#superclass : #Object,
	#instVars : [
		'specification'
	],
	#category : #'Stargate-REST-API-Model'
}

{ #category : #'instance creation' }
ReflectiveMappingRuleSetBuilder class >> for: aWebServiceSpecification [

	^ self new initializeFor: aWebServiceSpecification
]

{ #category : #building }
ReflectiveMappingRuleSetBuilder >> build [

	| builder |

	builder := MappingRuleSetBuilder new.

	(KeywordMessageSendingCollector
		sendingAllMessagesBeginningWith: 'add'
		andEndingWith: 'MappingIn:'
		to: specification 
		with: builder) value.

	^ builder build
]

{ #category : #initialization }
ReflectiveMappingRuleSetBuilder >> initializeFor: aWebServiceSpecification [

	specification := aWebServiceSpecification
]
