Class {
	#name : #RESTFulWebServiceSpecification,
	#superclass : #Object,
	#category : #'Stargate-REST-API'
}

{ #category : #acccessing }
RESTFulWebServiceSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]
