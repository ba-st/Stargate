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
		'scheme',
		'host',
		'port'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
WebOrigin class >> basedOn: aUrl [

	( self hasValidOrigin: aUrl )
		ifFalse: [ InstanceCreationFailed signal: ( '<1p> does not comply with a valid origin' expandMacrosWith: aUrl ) ].

	^ self new initializeBasedOn: aUrl
]

{ #category : #preconditions }
WebOrigin class >> hasValidOrigin: aZnUrl [

	| validOriginSchemes |

	validOriginSchemes := #(#http #https).

	^ aZnUrl hasScheme and: [ ( validOriginSchemes includes: aZnUrl scheme ) and: [ aZnUrl hasHost ] ]
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
WebOrigin >> initializeBasedOn: aZnUrl [ 
	
	scheme := aZnUrl scheme. 
	host := aZnUrl host. 
	port := aZnUrl port. 
]

{ #category : #printing }
WebOrigin >> printOn: stream [

	stream
		nextPutAll: scheme;
		nextPutAll: '://'.
	stream nextPutAll: host.
	( port isNil or: [ port = 80 ] )
		ifFalse: [ stream
				nextPut: $:;
				print: port
			]
]
