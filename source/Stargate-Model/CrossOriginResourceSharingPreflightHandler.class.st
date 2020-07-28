"
I'm a before filter handler for the preflight request.
"
Class {
	#name : #CrossOriginResourceSharingPreflightHandler,
	#superclass : #CrossOriginResourceSharingHandler,
	#instVars : [
		'allowOriginPolicy',
		'allowedMethodsByRoute',
		'optionalHeaderCommands'
	],
	#pools : [
		'CrossOriginResourceSharing'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'instance creation' }
CrossOriginResourceSharingPreflightHandler class >> allowing: anAllowOriginPolicy accessTo: allowMethods applying: headersCommands [

	^ self new initializeAllowing: anAllowOriginPolicy accessTo: allowMethods applying: headersCommands
]

{ #category : #'header names' }
CrossOriginResourceSharingPreflightHandler >> accessControlAllowHeaders [

	^ Headers >> #accessControlAllowHeaders
]

{ #category : #'header names' }
CrossOriginResourceSharingPreflightHandler >> accessControlAllowMethods [

	^ Headers >> #accessControlAllowMethods
]

{ #category : #'header names' }
CrossOriginResourceSharingPreflightHandler >> accessControlRequestHeaders [

	^ Headers >> #accessControlRequestHeaders
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingPreflightHandler >> collectAllowedHeadersFrom: request [

	request headers
		at: self accessControlRequestHeaders
		ifPresent: [ :requestedHeaders | 
			requestedHeaders
				splitOn: $,
				do: [ :header | self add: header trimBoth toHeaderNamed: self accessControlAllowHeaders ].
			self add: self accessControlAllowHeaders toHeaderNamed: self vary
			]
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingPreflightHandler >> collectAllowedMethodsFrom: allowedMethods [

	allowedMethods do: [ :method | self add: method toHeaderNamed: self accessControlAllowMethods ]
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingPreflightHandler >> collectAllowedOriginFrom: aRequest [

	allowOriginPolicy applyOn: self for: aRequest
]

{ #category : #'collecting headers' }
CrossOriginResourceSharingPreflightHandler >> collectOptionalHeaders [

	optionalHeaderCommands do: [ :command | command value: self ]
]

{ #category : #initialization }
CrossOriginResourceSharingPreflightHandler >> initializeAllowing: anAllowOriginPolicy accessTo: methods applying: aCommandCollection [ 

	allowOriginPolicy := anAllowOriginPolicy.
	allowedMethodsByRoute := methods.
	optionalHeaderCommands := aCommandCollection.
	
	headers := Dictionary new
]

{ #category : #'header names' }
CrossOriginResourceSharingPreflightHandler >> origin [

	^ Headers >> #origin
]

{ #category : #evaluating }
CrossOriginResourceSharingPreflightHandler >> teaEvalActionOnRequest: request [

	| response  |

	self withAllowedMethodsFor: request url do: [ :allowedMethods | 
		response := TeaResponse noContent.
		self collectAllowedOriginFrom: request.
		self collectAllowedMethodsFrom: allowedMethods.
		self collectAllowedHeadersFrom: request.
		self collectOptionalHeaders.
		self applyHeadersTo: response.
		request abort: response		
	 ].
]

{ #category : #'header names' }
CrossOriginResourceSharingPreflightHandler >> vary [

	^ Headers >> #vary
]

{ #category : #evaluating }
CrossOriginResourceSharingPreflightHandler >> withAllowedMethodsFor: aUrl do: aBlock [

	allowedMethodsByRoute keys
		detect: [ :route | route asTeaUrlPattern matchesUrl: aUrl placeholders: Dictionary new ]
		ifFound: [ :matchingRoute | aBlock value: ( allowedMethodsByRoute at: matchingRoute ) ]
]
