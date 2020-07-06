Class {
	#name : #CrossOriginResourceSharingAwareRouteSpecification,
	#superclass : #AbstractRouteSpecification,
	#instVars : [
		'specification'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingAwareRouteSpecification class >> decorating: aRouteSpecification [ 
	
	^ self new initializeDecorating: aRouteSpecification 
]

{ #category : #configuring }
CrossOriginResourceSharingAwareRouteSpecification >> configureUsing: aRouteConfigurator [

	aRouteConfigurator configureCrossOriginResourceSharingAwareRouteFrom: self  
]

{ #category : #initialization }
CrossOriginResourceSharingAwareRouteSpecification >> initializeDecorating: aRouteSpecification [

	specification := aRouteSpecification
]

{ #category : #accessing }
CrossOriginResourceSharingAwareRouteSpecification >> specification [

	^ specification
]
