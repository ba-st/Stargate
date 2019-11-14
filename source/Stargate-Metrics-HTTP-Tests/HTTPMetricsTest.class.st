"
A HTTPMetricsTest is a test class for testing the behavior of HTTPMetrics
"
Class {
	#name : #HTTPMetricsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-HTTP-Tests'
}

{ #category : #'private - asserting' }
HTTPMetricsTest >> assertMetricValuesIn: composite byCategoryAre: anArrayOfValues [

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

{ #category : #private }
HTTPMetricsTest >> getEventAt: anUrl respondingOkWith: text [

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
HTTPMetricsTest >> getEventRespondingNotFoundAt: anUrl [

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
HTTPMetricsTest >> is: aTimestampedMetric labeledWith: anHTTPMethod at: aUrl responding: anStatusCode [

	^ ( aTimestampedMetric metric labelAt: #http_method ) = anHTTPMethod
		and: [ ( aTimestampedMetric metric labelAt: #url ) = aUrl asString
				and: [ ( aTimestampedMetric metric labelAt: #response_code ) = anStatusCode ]
			]
]

{ #category : #private }
HTTPMetricsTest >> optionsEventRespondingNotFoundAt: anUrl [

	^ ZnServerTransactionEvent new
		request: ( ZnRequest options: anUrl );
		response: ( ZnResponse notFound: anUrl );
		timing:
			( ZnServerTransactionTiming new
				handlerDuration: 4;
				yourself );
		yourself
]

{ #category : #tests }
HTTPMetricsTest >> testEmptyMetricsWhenNoEventsWhereReceived [

	self assert: HTTPMetrics new gatherMetrics isEmpty
]

{ #category : #tests }
HTTPMetricsTest >> testGatherMetrics [

	| provider metrics countMetric sizeMetric durationMetric |

	provider := HTTPMetrics new.

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
HTTPMetricsTest >> testProviderName [

	self assert: HTTPMetrics providerName equals: 'http'
]
