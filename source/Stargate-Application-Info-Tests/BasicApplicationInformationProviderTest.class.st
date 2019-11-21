"
A BasicApplicationInformationProviderTest is a test class for testing the behavior of BasicApplicationInformationProvider
"
Class {
	#name : #BasicApplicationInformationProviderTest,
	#superclass : #TestCase,
	#category : #'Stargate-Application-Info-Tests'
}

{ #category : #tests }
BasicApplicationInformationProviderTest >> testGatherInformation [

	| provider info |

	provider := BasicApplicationInformationProvider new
		applicationNamed: 'A'
		describedBy: 'B'
		version: 'v2.0.1'.

	info := provider gatherInformation.

	self
		assert: info size equals: 3;
		assert: ( info at: 'name' ) equals: 'A';
		assert: ( info at: 'description' ) equals: 'B';
		assert: ( info at: 'version' ) equals: 'v2.0.1'
]
