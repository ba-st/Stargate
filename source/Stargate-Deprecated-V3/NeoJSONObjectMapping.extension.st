Extension { #name : #NeoJSONObjectMapping }

{ #category : #'*Stargate-Deprecated-V3' }
NeoJSONObjectMapping >> mapHypermediaControlsIn: aContext [

	self deprecated: 'Use mapAsHypermediaControls: searching for the controls related to a resource'.
	self error: 'Unsupported'
]
