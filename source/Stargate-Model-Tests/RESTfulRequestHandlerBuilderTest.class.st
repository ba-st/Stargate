"
I'm a test case for the configuration a RESTfulRequestHandlerBuilder refuses
"
Class {
	#name : 'RESTfulRequestHandlerBuilderTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'tests' }
RESTfulRequestHandlerBuilderTest >> testConfiguringADecodingRuleTwiceFails [

  | builder requestHandler request |
  builder := RESTfulRequestHandlerBuilder new
               handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
               whenAccepting: ZnMimeType textPlain decodeApplying: [ :contents | 'first rule' ];
               whenResponding: ZnMimeType textPlain encodeApplying: [ :resource | resource ];
               createEntityTagHashingEncodedResource;
               yourself.

  self
    should: [ builder whenAccepting: ZnMimeType textPlain decodeApplying: [ :contents | contents ] ]
    raise: AssertionFailed
    withMessageText: 'Decoding rule for media type already configured';
    should: [
        builder
          whenAccepting: ZnMimeType textPlain
          decodeFromJsonApplying: [ :json :reader | reader next ] ]
    raise: AssertionFailed withMessageText: 'Decoding rule for media type already configured';
    should: [ builder decodeToNeoJSONObjectWhenAccepting: ZnMimeType textPlain ]
    raise: AssertionFailed
    withMessageText: 'Decoding rule for media type already configured'.

  requestHandler := builder build.
  request := ZnRequest post: 'https://api.example.com/things'.
  request entity: ( ZnEntity text: 'contents' ).

  self
    assert: ( requestHandler
          decode: ( TeaRequest fromZnRequest: request pathParams: Dictionary new )
          within: HttpRequestContext new )
    equals: 'first rule'
]
