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

	error := HTTPNotAcceptable messageText: 'Ouch!' accepting: {'application/xml' asMediaType}.
	json := NeoJSONObject fromString: ( NeoJSONWriter toStringPretty: error ).

	self
		assert: json message equals: 'Ouch!';
		assert: json code equals: 406;
		assert: json allowedMediaTypes size equals: 1;
		assert: json allowedMediaTypes first equals: 'application/xml'
]
