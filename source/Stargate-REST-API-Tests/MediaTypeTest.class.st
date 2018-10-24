"
I'm a test for media type extensions
"
Class {
	#name : #MediaTypeTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests-Model'
}

{ #category : #tests }
MediaTypeTest >> testAccepts [

	| mediaType |

	mediaType := 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType.

	self
		assert: (mediaType accepts: mediaType);
		assert: (mediaType accepts: 'application/vnd.stargate.pet+json' asMediaType);
		assert: (mediaType accepts: 'application/json' asMediaType);
		assert: (mediaType accepts: 'application/*' asMediaType);
		assert: (mediaType accepts: '*/*' asMediaType);
		assert: (mediaType accepts: 'application/vnd.stargate.pet' asMediaType);
		assert: (mediaType accepts: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType).

	self
		deny: (mediaType accepts: 'text/*' asMediaType);
		deny: (mediaType accepts: 'application/xml' asMediaType)
]

{ #category : #tests }
MediaTypeTest >> testQuality [

	self
		assert: 'text/html' asMediaType quality equals: 1.0;
		assert: 'text/html;q=0.8' asMediaType quality equals: 0.8
]
