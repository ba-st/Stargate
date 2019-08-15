"
I'm an exception expecting to be raised when someone seeks a mapping and cannot find it.
"
Class {
	#name : #MappingNotFound,
	#superclass : #Error,
	#category : #'Stargate-Deprecated-V3'
}

{ #category : #deprecation }
MappingNotFound class >> isDeprecated [

	^ true
]
