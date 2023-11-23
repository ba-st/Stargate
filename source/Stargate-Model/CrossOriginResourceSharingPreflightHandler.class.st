"
I'm a before filter handler for the preflight request.
"
Class {
	#name : 'CrossOriginResourceSharingPreflightHandler',
	#superclass : 'CrossOriginResourceSharingHandler',
	#instVars : [
		'allowOriginPolicy',
		'allowedMethodsByRoute',
		'optionalHeaderCommands'
	],
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'instance creation' }
CrossOriginResourceSharingPreflightHandler class >> allowing: anAllowOriginPolicy accessTo: allowMethods applying: headersCommands [

	^ self new initializeAllowing: anAllowOriginPolicy accessTo: allowMethods applying: headersCommands
]

{ #category : 'initialization' }
CrossOriginResourceSharingPreflightHandler >> initializeAllowing: anAllowOriginPolicy accessTo: methods applying: aCommandCollection [ 

	allowOriginPolicy := anAllowOriginPolicy.
	allowedMethodsByRoute := methods.
	optionalHeaderCommands := aCommandCollection.
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingPreflightHandler >> setAllowedHeadersOn: aResponse from: aRequest [

	aRequest headers
		at: self headerNames >> #accessControlRequestHeaders
		ifPresent: [ :requestedHeaders |
			$, split: requestedHeaders do: [ :header |
				aResponse headers
					at: self headerNames >> #accessControlAllowHeaders
					addSeparatedWithComma: header trimBoth
				].
			aResponse addToVary: self headerNames >> #accessControlAllowHeaders
			]
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingPreflightHandler >> setAllowedMethodsOn: aResponse from: allowedMethods [

	allowedMethods
		do:
			[ :method | aResponse headers at: self headerNames >> #accessControlAllowMethods addSeparatedWithComma: method ]
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingPreflightHandler >> setAllowedOriginOn: aResponse from: aRequest [ 
	
	allowOriginPolicy applyOn: aResponse for: aRequest using: self
]

{ #category : 'private - evaluating' }
CrossOriginResourceSharingPreflightHandler >> setOptionalHeadersOn: aResponse [

	optionalHeaderCommands do: [ :command | command value: aResponse headers value: self headerNames ]
]

{ #category : 'evaluating' }
CrossOriginResourceSharingPreflightHandler >> teaEvalActionOnRequest: aRequest [

	| response |

	self
		withAllowedMethodsFor: aRequest url
		do: [ :allowedMethods | 
			response := ZnResponse noContent.
			self setAllowedOriginOn: response from: aRequest.
			self setAllowedMethodsOn: response from: allowedMethods.
			self setAllowedHeadersOn: response from: aRequest.
			self setOptionalHeadersOn: response.
			aRequest abort: response
			]
]

{ #category : 'evaluating' }
CrossOriginResourceSharingPreflightHandler >> withAllowedMethodsFor: aUrl do: aBlock [

	allowedMethodsByRoute keys
		detect: [ :route | route asTeaUrlPattern matchesUrl: aUrl placeholders: Dictionary new ]
		ifFound: [ :matchingRoute | aBlock value: ( allowedMethodsByRoute at: matchingRoute ) ]
]
