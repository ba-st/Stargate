"
I'm a reflective configurator of web service routes.

I'm being used to configure a Teapot server routes reflectively. I expect web service specification declare its routes on messages that follow the pattern #*Route
"
Class {
	#name : 'ReflectiveRoutesConfigurator',
	#superclass : 'Object',
	#instVars : [
		'teapot'
	],
	#category : 'Stargate-Model-Routing',
	#package : 'Stargate-Model',
	#tag : 'Routing'
}

{ #category : 'instance creation' }
ReflectiveRoutesConfigurator class >> appliedTo: aTeapot [ 
	
	^ self new initializeAppliedTo: aTeapot 
]

{ #category : 'configuring' }
ReflectiveRoutesConfigurator >> addRoutesOf: aResourceRESTfulController [

	(RouteConfigurator configuring: teapot withRoutesDefinedOn: aResourceRESTfulController) configure 
]

{ #category : 'initialization' }
ReflectiveRoutesConfigurator >> initializeAppliedTo: aTeapot [ 
	
	teapot := aTeapot
]
