Class {
	#name : #WebServiceSpecification,
	#superclass : #Object,
	#category : #'Stargate-REST-API'
}

{ #category : #acccessing }
WebServiceSpecification >> mappingRuleSet [

	^ (ReflectiveMappingRuleSetBuilder for: self) build
]
