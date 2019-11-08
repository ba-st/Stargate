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
		equals: aString
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
			'# HELP metric_without_timestamp_and_labels Minimalistic line:<l># TYPE metric_without_timestamp_and_labels counter<l>metric_without_timestamp_and_labels 12.47<l>'
				expandMacros
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testGaugeEncoding [

	self
		assertEncodingOf:
			( Gauge
				named: 'Metric without timestamp and labels'
				describedBy: 'Minimalistic line:'
				withValue: 1 )
		equals:
			'# HELP metric_without_timestamp_and_labels Minimalistic line:<l># TYPE metric_without_timestamp_and_labels gauge<l>metric_without_timestamp_and_labels 1<l>'
				expandMacros
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testLabeledAndTimestampedMetricEncodingForCounters [

	self
		assertEncodingOf:
			( CompositeMetricBuilder forCounter
				named: 'API HTTP request count';
				describedBy: 'The total number of HTTP requests.';
				addValue: 1027
					labeledBy: { #method -> 'post' . #code -> 200 }
					at: self timestamp ;
				addValue: 3
					labeledBy: { #method -> 'post' . #code -> 400 } 
					at: (DateAndTime year: 1970 month: 1 day: 2 offset: 0 asDuration);
				build )
		equals:
			'# HELP api_http_request_count The total number of HTTP requests.<l># TYPE api_http_request_count counter<l>api_http_request_count{method="post",code="200"} 1027 0<l>api_http_request_count{method="post",code="400"} 3 86400000<l>'
				expandMacros
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
			'# HELP api_http_request_count The total number of HTTP requests.<l># TYPE api_http_request_count counter<l>api_http_request_count{method="post",code="200"} 1027<l>api_http_request_count{method="post",code="400"} 3<l>'
				expandMacros
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
			'# HELP api_http_request_count The total number of HTTP requests.<l># TYPE api_http_request_count gauge<l>api_http_request_count{code="200"} 1027<l>api_http_request_count{code="400"} 3<l>'
				expandMacros
]

{ #category : #tests }
PrometheusMetricsEncoderTest >> testTimestampedCounterEncoding [

	self
		assertEncodingOf:
			( TimestampedMetric
				over: ( Counter named: 'Tenured count' describedBy: 'Number of objects tenured' withValue: 2500 )
				at: self timestamp )
		equals:
			'# HELP tenured_count Number of objects tenured<l># TYPE tenured_count counter<l>tenured_count 2500 0<l>'
				expandMacros
]

{ #category : #running }
PrometheusMetricsEncoderTest >> timestamp [

	^ DateAndTime unixEpoch
]
