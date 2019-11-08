"
I'm one of the operational plugins.
I provide metrics of the running system.
"
Class {
	#name : #MetricsPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'metrics'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #accessing }
MetricsPlugin class >> endpoint [

	^ 'metrics'
]

{ #category : #accessing }
MetricsPlugin class >> pluginName [

	^ 'Metrics'
]
