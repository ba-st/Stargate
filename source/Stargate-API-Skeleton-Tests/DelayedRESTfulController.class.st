"
I'm a example of a RESTful controller:
- only implementing GET operations
- not paginating collections
- not using hypermedia
"
Class {
	#name : 'DelayedRESTfulController',
	#superclass : 'SingleResourceRESTfulController',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'routes' }
DelayedRESTfulController >> declareWaitRoute [

	^ RouteSpecification handling: #GET at: self endpoint evaluating: [ :httpRequest :requestContext |
		  100 milliSeconds wait.
		  ZnResponse ok: ( ZnEntity text: 'OK' )
		  ]
]

{ #category : 'initialization' }
DelayedRESTfulController >> initialize [

	super initialize.
	requestHandler := RESTfulRequestHandlerBuilder new
		                  handling: 'wait';
		                  createEntityTagHashingEncodedResource;
		                  build
]

{ #category : 'private' }
DelayedRESTfulController >> requestHandler [

	^ requestHandler 
]

{ #category : 'private' }
DelayedRESTfulController >> typeIdConstraint [

	^ IsObject
]
