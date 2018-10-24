Class {
	#name : #RESTFulWebServiceSpecification,
	#superclass : #Object,
	#category : #'Stargate-REST-API-Model'
}

{ #category : #acccessing }
RESTFulWebServiceSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]

{ #category : #acccessing }
RESTFulWebServiceSpecification >> mediaTypes [

	^ (UnaryMessageSendingCollector sendingAllMessagesEndingWith: 'MediaType' to: self) value
]
