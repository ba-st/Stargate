Class {
	#name : #CrossOriginResourceSharingFilterBuilderTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-CORS'
}

{ #category : #tests }
CrossOriginResourceSharingFilterBuilderTest >> testBuildActualRequestFilter [

	| filter teapot |

	filter := ( CrossOriginResourceSharingFilterBuilder using: {PetsRESTfulController new} )
		allowAnyOrigin;
		doNotCache;
		buildActualRequestFilter.

	teapot := Teapot on.

	self assert: teapot beforeFilters isEmpty.
	filter applyOn: teapot.
	self assert: teapot afterFilters size equals: 1
]

{ #category : #tests }
CrossOriginResourceSharingFilterBuilderTest >> testBuildPreflightFilter [

	| filter teapot |

	filter := ( CrossOriginResourceSharingFilterBuilder using: {PetsRESTfulController new} )
		allowAnyOrigin;
		allowCredentials;
		expireIn: 600 seconds;
		expose: #('Authorization');
		buildPreflightFilter.

	teapot := Teapot on.
	self assert: teapot beforeFilters isEmpty.
	filter applyOn: teapot.
	self assert: teapot beforeFilters size equals: 1
]
