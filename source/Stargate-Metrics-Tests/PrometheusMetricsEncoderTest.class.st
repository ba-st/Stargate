"
A PrometheusMetricsEncoderTest is a test class for testing the behavior of PrometheusMetricsEncoder
"
Class {
	#name : #PrometheusMetricsEncoderTest,
	#superclass : #TestCase,
	#instVars : [
		'encoder'
	],
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #asserting }
PrometheusMetricsEncoderTest >> assertEncodingOf: aMetric equals: aString [

	self
		assert: ( String streamContents: [ :stream | encoder encode: aMetric on: stream ] )
		equals: ( aString expandMacrosWith: Character lf asString )
]

{ #category : #running }
PrometheusMetricsEncoderTest >> setUp [

	super setUp.
	encoder := PrometheusMetricsEncoder new
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testCounterEncoding [

	self
		assertEncodingOf:
			( Counter
				named: 'Metric without timestamp and labels'
				describedBy: 'Minimalistic line:'
				withValue: 12.47 )
		equals:
			'# HELP metric_without_timestamp_and_labels Minimalistic line:<1s># TYPE metric_without_timestamp_and_labels counter<1s>metric_without_timestamp_and_labels 12.47<1s>'
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testGaugeEncoding [

	self
		assertEncodingOf:
			( Gauge named: 'Metric without timestamp and labels' describedBy: 'Minimalistic line:' withValue: 1 )
		equals:
			'# HELP metric_without_timestamp_and_labels Minimalistic line:<1s># TYPE metric_without_timestamp_and_labels gauge<1s>metric_without_timestamp_and_labels 1<1s>'
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testLabeledAndTimestampedMetricEncodingForCounters [

	self
		assertEncodingOf: ( CompositeMetricBuilder forCounter
				  named: 'API HTTP request count';
				  describedBy: 'The total number of HTTP requests.';
				  addValue: 1027 labeledBy: {
						  ( #method -> 'post' ).
						  ( #code -> 200 ) }
				  at: self timestamp;
				  addValue: 3 labeledBy: {
						  ( #method -> 'post' ).
						  ( #code -> 400 ) }
				  at: ( DateAndTime
						    year: 1970
						    month: 1
						    day: 2
						    hour: 0
						    minute: 0
						    second: 0
						    offset: 0 asDuration );
				  build )
		equals:
		'# HELP api_http_request_count The total number of HTTP requests.<1s># TYPE api_http_request_count counter<1s>api_http_request_count{method="post",code="200"} 1027 0<1s>api_http_request_count{method="post",code="400"} 3 86400000<1s>'
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testLabeledMetricEncodingForCounters [

	self
		assertEncodingOf:
			( CompositeMetricBuilder forCounter
				named: 'API HTTP request count';
				describedBy: 'The total number of HTTP requests.';
				addValue: 1027
					labeledBy: { #method -> 'post' . #code -> 200 };
				addValue: 3
					labeledBy: { #method -> 'post' . #code -> 400 };
				build )
		equals:
			'# HELP api_http_request_count The total number of HTTP requests.<1s># TYPE api_http_request_count counter<1s>api_http_request_count{method="post",code="200"} 1027<1s>api_http_request_count{method="post",code="400"} 3<1s>'
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testLabeledMetricEncodingForGauges [

	self
		assertEncodingOf:
			( CompositeMetricBuilder forGauge
				named: 'API HTTP request count';
				describedBy: 'The total number of HTTP requests.';
				addValue: 1027 labeledBy: { #code -> 200 };
				addValue: 3 labeledBy: { #code -> 400 };
				build )
		equals:
			'# HELP api_http_request_count The total number of HTTP requests.<1s># TYPE api_http_request_count gauge<1s>api_http_request_count{code="200"} 1027<1s>api_http_request_count{code="400"} 3<1s>'
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testTimestampedCounterEncoding [

	self
		assertEncodingOf:
			( TimestampedMetric
				over: ( Counter named: 'Tenured count' describedBy: 'Number of objects tenured' withValue: 2500 )
				at: self timestamp )
		equals:
			'# HELP tenured_count Number of objects tenured<1s># TYPE tenured_count counter<1s>tenured_count 2500 0<1s>'
]

{ #category : #running }
PrometheusMetricsEncoderTest >> timestamp [

	^ DateAndTime unixEpoch
]
