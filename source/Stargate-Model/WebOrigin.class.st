"
I represent a web origin as defined in the RFC 6454.
I have the format 
	scheme '://' host [ ':' port ]
with <scheme>, <host>, <port> from RFC 3986.
	
The // precedes the authority component of the uri, and thus I accept the schemes
that may have the authority component. Currently #(http https) but this can be extended at will. 
	
References
	https://tools.ietf.org/html/rfc6454
	https://tools.ietf.org/html/rfc3986
"
Class {
	#name : #WebOrigin,
	#superclass : #Object,
	#instVars : [
		'url'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
WebOrigin class >> basedOn: aUrl [

	AssertionChecker
		enforce: [ self hasValidOrigin: aUrl ]
		because: [ '<1p> does not comply with a valid origin' expandMacrosWith: aUrl ]
		raising: InstanceCreationFailed.

	^ self new initializeBasedOn: aUrl
]

{ #category : #preconditions }
WebOrigin class >> hasValidOrigin: aUrl [

	| validOriginSchemes |

	validOriginSchemes := #(#http #https).

	^ aUrl hasScheme and: [ ( validOriginSchemes includes: aUrl scheme ) and: [ aUrl hasHost ] ]
]

{ #category : #comparing }
WebOrigin >> = aWebOrigin [

	^ self asString = aWebOrigin asString
]

{ #category : #comparing }
WebOrigin >> hash [

	^ self asString hash
]

{ #category : #initialization }
WebOrigin >> initializeBasedOn: aUrl [ 
	
	url := aUrl
]

{ #category : #printing }
WebOrigin >> printOn: stream [

	stream
		nextPutAll: url scheme;
		nextPutAll: '://';
		nextPutAll: url host.
	url portOrDefault = ( ZnUrl defaultPortForScheme: url scheme )
		ifFalse: [ stream
				nextPut: $:;
				print: url port
			]
]
