"
I'm testing extensions to classes in the Hyperspace project
"
Class {
	#name : #HyperspaceExtensionsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Extensions'
}

{ #category : #tests }
HyperspaceExtensionsTest >> testBadRequestAsJSON [

	| error json |

	error := HTTPClientError badRequest messageText: 'Ouch!'.
	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: error ).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 400
]

{ #category : #tests }
HyperspaceExtensionsTest >> testNotAcceptableAsJSON [

	| error json |

	error := HTTPNotAcceptable
		messageText: 'Ouch!'
		accepting: {'application/xml' asMediaType}
		inAnyOf: ( #('en-us' 'es-ar') collect: #asLanguageTag ).
	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: error ).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 406;
		assert: json allowedMediaTypes size equals: 1;
		assert: json allowedMediaTypes first equals: 'application/xml';
		assert: json allowedLanguageTags size equals: 2;
		assert: json allowedLanguageTags first equals: 'en-US';
		assert: json allowedLanguageTags last equals: 'es-AR'
]
