"
A HTTPMetricsTest is a test class for testing the behavior of HTTPMetrics
"
Class {
	#name : #HTTPMetricsProviderTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-HTTP-Tests'
}

{ #category : #'private - asserting' }
HTTPMetricsProviderTest >> assertMetricValuesIn: composite byCategoryAre: anArrayOfValues [

	self assert: composite metrics size equals: 4.

	composite metrics
		detect: [ :metric | 
			self
				is: metric
				labeledWith: #GET
				at: '/secure'
				responding: 200
			]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues first ]
			ifNone: [ self fail ];
		detect: [ :metric | 
			self
				is: metric
				labeledWith: #GET
				at: '/unsecure'
				responding: 200
			]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues second ]
			ifNone: [ self fail ];
		detect: [ :metric | 
			self
				is: metric
				labeledWith: #GET
				at: '/unsecure'
				responding: 404
			]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues third ]
			ifNone: [ self fail ];
		detect: [ :metric | 
			self
				is: metric
				labeledWith: #OPTIONS
				at: '/secure'
				responding: 404
			]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues last ]
			ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
HTTPMetricsProviderTest >> assertMetricValuesIn: composite byMethodAre: anArrayOfValues [

	self assert: composite metrics size equals: 2.

	composite metrics
		detect: [ :metric | self is: metric labeledWith: #GET ]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues first ]
			ifNone: [ self fail ];
		detect: [ :metric | self is: metric labeledWith: #OPTIONS ]
			ifFound: [ :metric | self assert: metric value equals: anArrayOfValues last ]
			ifNone: [ self fail ]
]

{ #category : #private }
HTTPMetricsProviderTest >> getEventAt: anUrl respondingOkWith: text [

	^ ZnSimplifiedServerTransactionEvent new
		request: ( ZnRequest get: anUrl );
		response: ( ZnResponse ok: ( ZnEntity text: text ) );
		timing:
			( ZnServerTransactionTiming new
				handlerDuration: 3;
				yourself );
		yourself
]

{ #category : #private }
HTTPMetricsProviderTest >> getEventRespondingNotFoundAt: anUrl [

	^ ZnSimplifiedServerTransactionEvent new
		request: ( ZnRequest get: anUrl );
		response: ( ZnResponse notFound: anUrl );
		timing:
			( ZnServerTransactionTiming new
				handlerDuration: 3;
				yourself );
		yourself
]

{ #category : #private }
HTTPMetricsProviderTest >> is: aTimestampedMetric labeledWith: anHTTPMethod [

	^ ( aTimestampedMetric metric labelAt: #http_method ) = anHTTPMethod
]

{ #category : #private }
HTTPMetricsProviderTest >> is: aTimestampedMetric labeledWith: anHTTPMethod at: aUrl responding: aStatusCode [

	^ ( self is: aTimestampedMetric labeledWith: anHTTPMethod )
		and: [ ( aTimestampedMetric metric labelAt: #url ) = aUrl asString
				and: [ ( aTimestampedMetric metric labelAt: #response_code ) = aStatusCode ]
			]
]

{ #category : #private }
HTTPMetricsProviderTest >> optionsEventRespondingNotFoundAt: anUrl [

	^ ZnServerTransactionEvent new
		request:
			( ( ZnRequest options: anUrl )
				setUrlTemplate: '*';
				yourself );
		response: ( ZnResponse notFound: anUrl );
		timing:
			( ZnServerTransactionTiming new
				handlerDuration: 4;
				yourself );
		yourself
]

{ #category : #tests }
HTTPMetricsProviderTest >> testEmptyMetricsWhenNoEventsWhereReceived [

	self assert: HTTPMetricsProvider new gatherMetrics isEmpty
]

{ #category : #tests }
HTTPMetricsProviderTest >> testGatherMetrics [

	| provider metrics countMetric sizeMetric durationMetric |

	provider := HTTPMetricsProvider new.

	provider
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/unsecure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventRespondingNotFoundAt: '/unsecure' asUrl );
		handleEvent: ( self optionsEventRespondingNotFoundAt: '/secure' asUrl ).

	metrics := provider gatherMetrics.

	self assert: metrics size equals: 3.

	countMetric := metrics first.

	self
		assert: countMetric name equals: 'HTTP request count';
		assert: countMetric description equals: 'Number of HTTP requests received';
		assert: countMetric value equals: 5;
		assertMetricValuesIn: countMetric byCategoryAre: #(2 1 1 1).

	sizeMetric := metrics second.

	self
		assert: sizeMetric name equals: 'HTTP response size in bytes';
		assert: sizeMetric description equals: 'Size in bytes of content in the HTTP responses';
		assert: sizeMetric value equals: 46;
		assertMetricValuesIn: sizeMetric byCategoryAre: #(4 2 21 19).

	durationMetric := metrics last.

	self
		assert: durationMetric name equals: 'HTTP request/response duration in ms';
		assert: durationMetric description
			equals: 'Milliseconds to process a request and produce a response';
		assert: durationMetric value equals: 16;
		assertMetricValuesIn: durationMetric byCategoryAre: #(6 3 3 4)
]

{ #category : #tests }
HTTPMetricsProviderTest >> testGatherMetricsIncludingTemplates [

	| provider metrics countMetric |

	provider := HTTPMetricsProvider new.

	provider
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/unsecure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventRespondingNotFoundAt: '/unsecure' asUrl );
		handleEvent: ( self optionsEventRespondingNotFoundAt: '/secure' asUrl ).

	metrics := provider gatherMetrics.

	self assert: metrics size equals: 3.

	countMetric := metrics first.
	countMetric metrics
		detect: [ :metric | metric printString includesSubstring: '#url_template=''*''' ]
		ifFound: [ :metric | self assert: metric value equals: 1 ]
		ifNone: [ self fail ]
]

{ #category : #tests }
HTTPMetricsProviderTest >> testGatherMetricsProvidingBreakdownConfiguration [

	| provider metrics countMetric sizeMetric durationMetric |

	provider := HTTPMetricsProvider
		configuredBy:
			( Dictionary new
				at: HTTPMetricsProvider providerName
					put:
					( Dictionary new
						at: #breakdownCategories put: #(#http_method);
						yourself );
				yourself ).

	provider
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/secure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventAt: '/unsecure' asUrl respondingOkWith: 'OK' );
		handleSimplifiedEvent: ( self getEventRespondingNotFoundAt: '/unsecure' asUrl );
		handleEvent: ( self optionsEventRespondingNotFoundAt: '/secure' asUrl ).

	metrics := provider gatherMetrics.

	self assert: metrics size equals: 3.

	countMetric := metrics first.

	self
		assert: countMetric name equals: 'HTTP request count';
		assert: countMetric description equals: 'Number of HTTP requests received';
		assert: countMetric value equals: 5;
		assertMetricValuesIn: countMetric byMethodAre: #(4 1).

	sizeMetric := metrics second.

	self
		assert: sizeMetric name equals: 'HTTP response size in bytes';
		assert: sizeMetric description equals: 'Size in bytes of content in the HTTP responses';
		assert: sizeMetric value equals: 46;
		assertMetricValuesIn: sizeMetric byMethodAre: #(27 19).

	durationMetric := metrics last.

	self
		assert: durationMetric name equals: 'HTTP request/response duration in ms';
		assert: durationMetric description
			equals: 'Milliseconds to process a request and produce a response';
		assert: durationMetric value equals: 16;
		assertMetricValuesIn: durationMetric byMethodAre: #(12 4)
]

{ #category : #tests }
HTTPMetricsProviderTest >> testProviderName [

	self assert: HTTPMetricsProvider providerName equals: 'http'
]
