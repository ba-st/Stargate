"
I'm a Test Case for AcceptNegotiator
"
Class {
	#name : #RESTfulControllerAcceptNegotiatorTest,
	#superclass : #TestCase,
	#instVars : [
		'apiMediaTypes',
		'allowedLanguageTags'
	],
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #'private - asserting' }
RESTfulControllerAcceptNegotiatorTest >> assertBestLanguageFor: aLanguageProrityList given: theAvailableLanguageTags is: expectedLanguage [

	self
		assert:
			( self
				bestLanguageFor: aLanguageProrityList
				given: ( theAvailableLanguageTags collect: #asLanguageTag ) )
		equals: expectedLanguage asLanguageTag
]

{ #category : #'private - asserting' }
RESTfulControllerAcceptNegotiatorTest >> assertBestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes is: aMediaType [

	self assert: (self bestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes) equals: aMediaType
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiatorTest >> bestLanguageFor: aLanguageProrityList given: theAvailableLanguageTags [

	^ ( RESTfulControllerAcceptNegotiator accepting: #() inAnyOf: theAvailableLanguageTags )
		bestLanguageFor:
			( ( ZnRequest get: '/example' asZnUrl )
				setAcceptLanguage: aLanguageProrityList;
				yourself )
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiatorTest >> bestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes [

	^ (RESTfulControllerAcceptNegotiator accepting: theAvailableMediaTypes)
		bestRepresentationFor:
			((ZnRequest get: '/example' asZnUrl)
				setAccept: anAcceptHeaderContent;
				yourself)
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiatorTest >> pearAcceptHeader [

	^ 'text/html,application/xhtml+xml,application/xml;q=0.9,text/*;q=0.7,*/*,image/gif; q=0.8, image/jpeg; q=0.6, image/*'
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiatorTest >> rfcHeader [

	^ 'text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5'
]

{ #category : #running }
RESTfulControllerAcceptNegotiatorTest >> setUp [

	super setUp.
	apiMediaTypes := Array
		with: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType
		with: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType
		with: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType
		with: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType.
	allowedLanguageTags := #('en' 'es-AR' 'es-MX') collect: #asLanguageTag
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testAPIExactMatch [

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0.0' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json;version=1.0.0' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testAcceptHeaderContentIsAnArray [

	"Fixes a bug discovered when using the Consul HTTP Check method and configuring an Accept header on the check"

	| request |

	request := ZnRequest
		readFrom:
			( 'GET /example HTTP/1.1<1s><2s>User-Agent: Consul Agent<1s><2s>Accept: */*<1s><2s>Accept: application/json<1s><2s>'
				expandMacrosWith: Character cr asString
				with: Character lf asString ) readStream.

	self
		assert: ( ( RESTfulControllerAcceptNegotiator accepting: apiMediaTypes ) bestRepresentationFor: request )
		equals: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testAcceptingAnything [

	self
		assertBestRepresentationFor: '*/*'
		given: apiMediaTypes
		is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType
]

{ #category : #'tests - languages' }
RESTfulControllerAcceptNegotiatorTest >> testInvalidLanguageRangesAreIgnored [

	self
		assertBestLanguageFor: ';q=1, en-nz' given: #('en-us' 'en-nz' 'en-au') is: 'en-nz';
		assertBestLanguageFor: '-, en' given: #('en-us' 'en-nz' 'en-au') is: 'en-us'
]

{ #category : #'tests - languages' }
RESTfulControllerAcceptNegotiatorTest >> testLanguageWithQualityLevel [

	self
		assertBestLanguageFor: 'en-au;q=0.6, en-us' given: #('en-us' 'en-nz' 'en-au') is: 'en-us';
		assertBestLanguageFor: 'en-au;q=0.6, en-nz;q=0.6' given: #('en-us' 'en-nz' 'en-au') is: 'en-au';
		assertBestLanguageFor: 'en;q=0.1, es;q=0.7, es-ar;q=0.8'
			given: #('en-us' 'en-nz' 'en-au' 'es-ES' 'es-ar')
			is: 'es-AR'
]

{ #category : #'tests - languages' }
RESTfulControllerAcceptNegotiatorTest >> testLanguageWithoutQualityLevel [

	self
		assertBestLanguageFor: 'en-us' given: #('en-us' 'en-nz' 'en-au') is: 'en-us';
		assertBestLanguageFor: 'en' given: #('en-us' 'en-nz' 'en-au') is: 'en-us';
		assertBestLanguageFor: 'en-au' given: #('en-us' 'en-nz' 'en-au') is: 'en-au';
		assertBestLanguageFor: 'es-au, en ' given: #('en-us' 'en-nz' 'en-au') is: 'en-us';
		assertBestLanguageFor: 'en-au, en-us ' given: #('en-us' 'en-nz' 'en-au') is: 'en-au';
		assertBestLanguageFor: '*' given: #('en-us' 'en-nz' 'en-au') is: 'en-us';
		assertBestLanguageFor: 'es, *' given: #('en-us' 'en-nz' 'en-au') is: 'en-us'
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testMissingVersionSelectsTheNewOne [

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #'tests - languages' }
RESTfulControllerAcceptNegotiatorTest >> testNoLanguageIsAcceptable [

	self
		should: [ self bestLanguageFor: 'en-us' given: #() ]
			raise: HTTPNotAcceptable
			withExceptionDo: [ :error | 
			self
				assert: error messageText
					equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error allowedLanguageTags isEmpty
			];
		should: [ self bestLanguageFor: 'en-us' given: {'en' asLanguageTag} ]
			raise: HTTPNotAcceptable
			withExceptionDo: [ :error | 
			self
				assert: error messageText
					equals: 'Cannot generate a response entity with acceptable characteristics.';
				withTheOnlyOneIn: error allowedLanguageTags
					do: [ :languageTag | self assert: languageTag equals: 'en' asLanguageTag ]
			];
		should: [ self bestLanguageFor: '' given: {'en' asLanguageTag} ]
			raise: HTTPNotAcceptable
			withMessageText: 'Cannot generate a response entity with acceptable characteristics.'
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testRFC2616Sec14 [

	self
		assertBestRepresentationFor: self rfcHeader
			given: {'text/html;level=1' asMediaType}
			is: 'text/html;level=1' asMediaType;
		assertBestRepresentationFor: self pearAcceptHeader
			given:
			{'application/xml' asMediaType.
			'text/plain' asMediaType}
			is: 'application/xml' asMediaType
]

{ #category : #tests }
RESTfulControllerAcceptNegotiatorTest >> testSemanticVersioning [

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=2' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.1' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json;version=1' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=2,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType.

	self
		assertBestRepresentationFor: 'application/json;version=2' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/json' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType.

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0.0;q=0.9,application/vnd.stargate.pet.summary+json;version=1.0.0'
		given: apiMediaTypes
		is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType.

	self
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+json;version=3' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+json;version=2.3.0' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+xml' given: apiMediaTypes ] raise: HTTPClientError
]
