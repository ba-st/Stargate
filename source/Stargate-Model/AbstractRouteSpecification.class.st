Class {
	#name : #AbstractRouteSpecification,
	#superclass : #Object,
	#category : #'Stargate-Model-Routing'
}

{ #category : #configuring }
AbstractRouteSpecification >> configureUsing: aRouteConfigurator [

	self subclassResponsibility
]
