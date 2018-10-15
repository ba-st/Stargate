Class {
	#name : #CrossOriginResourceSharingAwareRouteSpecification,
	#superclass : #Object,
	#instVars : [
		'specification'
	],
	#category : #'Stargate-REST-API-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingAwareRouteSpecification class >> decorating: aRouteSpecification [ 
	
	^ self new initializeDecorating: aRouteSpecification 
]

{ #category : #configuring }
CrossOriginResourceSharingAwareRouteSpecification >> configureUsing: aRouteConfigurator [

	aRouteConfigurator configureCorsAwareRouteFrom: self  
]

{ #category : #initialization }
CrossOriginResourceSharingAwareRouteSpecification >> initializeDecorating: aRouteSpecification [

	specification := aRouteSpecification
]

{ #category : #accessing }
CrossOriginResourceSharingAwareRouteSpecification >> specification [

	^ specification
]
