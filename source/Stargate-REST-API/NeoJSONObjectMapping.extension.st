Extension { #name : #NeoJSONObjectMapping }

{ #category : #'*Stargate-REST-API' }
NeoJSONObjectMapping >> mapAsHypermediaControls: aBlock [

	self mapProperty: #links getter: [ :object | (aBlock cull: object) asDictionary ] setter: [ :object :value |  ]
]

{ #category : #'*Stargate-REST-API' }
NeoJSONObjectMapping >> mapHypermediaControlsIn: aContext [

	self mapAsHypermediaControls: [ aContext hypermediaControls ]
]
