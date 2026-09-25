"
A CachingDirectivesBuilderTest is a test class for testing the behavior of CachingDirectivesBuilder
"
Class {
	#name : 'CachingDirectivesBuilderTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Caching',
	#package : 'Stargate-Model-Tests',
	#tag : 'Caching'
}

{ #category : 'private - asserting' }
CachingDirectivesBuilderTest >> assertExpiresHeaderFor: response with: aDuration [

	| oneMinuteBeforeFourHours fourHoursInTheFuture expiresString |

	expiresString := response headers at: #expires ifAbsent: [ self fail ].
	
	"This is just in case the test runs at a time when the minute has changed"
	oneMinuteBeforeFourHours := ZnUtils httpDate: DateAndTime now + aDuration - 1 minute.
	fourHoursInTheFuture := ZnUtils httpDate: DateAndTime now + aDuration.

	self
		assert: ( expiresString = oneMinuteBeforeFourHours or: [ expiresString = fourHoursInTheFuture ] )
]

{ #category : 'private - asserting' }
CachingDirectivesBuilderTest >> assertThereAre: aNumber directivesFrom: aBuilder whichSetCacheControlHeaderTo: anArray [

	| directives response |

	directives := aBuilder build.
	self assert: directives size equals: aNumber.
	response := self responseAffectedBy: directives.
	self assert: response cachingDirectives equals: anArray
]

{ #category : 'private - asserting' }
CachingDirectivesBuilderTest >> assertThereAre: aNumber directivesFrom: aBuilder whichSetExpiresHeaderTo: aDuration andCacheControlHeaderTo: anArray [

	| directives response |

	directives := aBuilder build.
	self assert: directives size equals: aNumber.
	response := self responseAffectedBy: directives.
	self assert: response cachingDirectives equals: anArray.
	self assertExpiresHeaderFor: response with: aDuration
]

{ #category : 'private - accessing' }
CachingDirectivesBuilderTest >> requestContext [

	^ HttpRequestContext new
]

{ #category : 'private - accessing' }
CachingDirectivesBuilderTest >> responseAffectedBy: directives [

  ^ self responseAffectedBy: directives within: self requestContext
]

{ #category : 'private - accessing' }
CachingDirectivesBuilderTest >> responseAffectedBy: directives within: aRequestContext [

  | response resource |
  resource := 'theResource'.
  response := ZnResponse ok: ( ZnStringEntity text: resource ).
  directives do: [ :directive | directive cull: response cull: aRequestContext cull: resource ].
  ^ response
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testAllowStaleOnErrorFor [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching allowStaleOnErrorFor: 1 day ];
               yourself.
  self
    assertThereAre: 1
    directivesFrom: builder
    whichSetCacheControlHeaderTo: #( 'stale-if-error=86400' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testAllowStaleWhileRevalidatingFor [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching allowStaleWhileRevalidatingFor: 30 seconds ];
               yourself.
  self
    assertThereAre: 1
    directivesFrom: builder
    whichSetCacheControlHeaderTo: #( 'stale-while-revalidate=30' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBeAvailableFor [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching beAvailableFor: 6 hours ];
               yourself.
  self
    assertThereAre: 3
    directivesFrom: builder
    whichSetExpiresHeaderTo: 6 hours
    andCacheControlHeaderTo: #( 'public' 'max-age=21600' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBeImmutable [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching beImmutable ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('immutable')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBePrivate [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching bePrivate ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('private')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBePrivateRestrictedTo [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching bePrivateRestrictedTo: ( Array with: 'server' with: 'user' ) ];
		yourself.
	self
		assertThereAre: 1
		directivesFrom: builder
		whichSetCacheControlHeaderTo: #('private="server, user"')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBePublic [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching bePublic ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('public')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBeStaleAfter [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching beStaleAfter: 2 minutes ];
               yourself.
  self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #( 'max-age=120' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testBuild [

	self assert: CachingDirectivesBuilder new build isEmpty
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testConfigureUsing [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching doNotTransform ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('no-transform')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testDoNotCache [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching doNotCache ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('no-cache')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testDoNotCacheRestrictedTo [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching doNotCacheRestrictedTo: ( Array with: 'account' ) ];
		yourself.
	self
		assertThereAre: 1
		directivesFrom: builder
		whichSetCacheControlHeaderTo: #('no-cache="account"')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testDoNotExpire [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching doNotExpire ];
               yourself.
  self
    assertThereAre: 4
    directivesFrom: builder
    whichSetExpiresHeaderTo: 365000000 seconds
    andCacheControlHeaderTo: #( 'immutable' 'public' 'max-age=365000000' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testDoNotStore [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching doNotStore ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('no-store')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testDoNotTransform [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching doNotTransform ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('no-transform')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testExpireIn [

	| directives response builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching expireIn: 3 hours ];
		yourself.

	directives := builder build.
	self assert: directives size equals: 1.
	response := self responseAffectedBy: directives.
	self assertExpiresHeaderFor: response with: 3 hours
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testMustRevalidate [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching mustRevalidate ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('must-revalidate')
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testRequireRevalidation [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching requireRevalidation ];
               yourself.
  self
    assertThereAre: 2
    directivesFrom: builder
    whichSetCacheControlHeaderTo: #( 'no-cache' 'max-age=0' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testWhenApplyWithConditionOnTheRequestContext [

  | directives administratorResponse anonymousResponse |
  directives := CachingDirectivesBuilder new
                  configureUsing: [ :caching |
                      caching
                        when: [ :response :resource :context |
                            context includesPermission: #administrator ]
                        apply: [ caching bePrivate ];
                        when: [ :response :resource :context |
                            ( context includesPermission: #administrator ) not ]
                        apply: [
                            caching
                              bePublic;
                              expireIn: 1 hour
                          ]
                    ];
                  build.

  administratorResponse := self responseAffectedBy: directives within: ( HttpRequestContext new
                                 permissions: #( #administrator );
                                 yourself ).
  self
    assert: administratorResponse cachingDirectives equals: #( 'private' );
    deny: ( administratorResponse headers includesKey: 'Expires' ).

  anonymousResponse := self responseAffectedBy: directives within: HttpRequestContext new.
  self
    assert: anonymousResponse cachingDirectives equals: #( 'public' );
    assertExpiresHeaderFor: anonymousResponse with: 1 hour
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testWhenApplyWithConditionOnTheResponse [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching |
                   caching
                     when: [ :response | response isSuccess ] apply: [
                         caching
                           bePublic;
                           expireIn: 4 hours
                       ];
                     when: [ :response | response isSuccess not ] apply: [ caching doNotStore ]
                 ];
               yourself.
  self
    assertThereAre: 3
    directivesFrom: builder
    whichSetExpiresHeaderTo: 4 hours
    andCacheControlHeaderTo: #( 'public' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testWhenApplyWithConditionOnTheResponseAndResource [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching |
                   caching
                     when: [ :response :resource | resource = 'theResource' ] apply: [
                         caching
                           bePublic;
                           expireIn: 4 hours
                       ];
                     when: [ :response :resource | resource ~= 'theResource' ]
                     apply: [ caching doNotStore ]
                 ];
               yourself.
  self
    assertThereAre: 3
    directivesFrom: builder
    whichSetExpiresHeaderTo: 4 hours
    andCacheControlHeaderTo: #( 'public' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testWhenSharedBeStaleAfter [

  | builder |
  builder := CachingDirectivesBuilder new
               configureUsing: [ :caching | caching whenSharedBeStaleAfter: 15 minutes ];
               yourself.
  self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #( 's-maxage=900' )
]

{ #category : 'tests' }
CachingDirectivesBuilderTest >> testWhenSharedMustRevalidate [

	| builder |

	builder := CachingDirectivesBuilder new
		configureUsing: [ :caching | caching whenSharedMustRevalidate ];
		yourself.
	self assertThereAre: 1 directivesFrom: builder whichSetCacheControlHeaderTo: #('proxy-revalidate')
]
