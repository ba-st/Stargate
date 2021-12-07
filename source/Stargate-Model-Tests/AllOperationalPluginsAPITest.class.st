Class {
	#name : #AllOperationalPluginsAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #running }
AllOperationalPluginsAPITest >> enable: pluginClass in: operationsConfiguration [

	operationsConfiguration at: pluginClass endpoint put: { #enabled -> true } asDictionary
]

{ #category : #running }
AllOperationalPluginsAPITest >> operationsConfiguration [

	| operationsConfiguration |

	operationsConfiguration := super operationsConfiguration.
	self
		enable: HealthCheckPlugin in: operationsConfiguration;
		enable: MetricsPlugin in: operationsConfiguration;
		enable: ApplicationInfoPlugin in: operationsConfiguration;
		enable: ApplicationConfigurationPlugin in: operationsConfiguration;
		enable: ApplicationControlPlugin in: operationsConfiguration;
		enable: LoggersPlugin in: operationsConfiguration.

	^ operationsConfiguration
]

{ #category : #running }
AllOperationalPluginsAPITest >> requiredPermissions [

	^ #('read:operations')
]

{ #category : #tests }
AllOperationalPluginsAPITest >> testGetOperationalPlugins [

	"This case is similar to OperationalPluginsAPITest>>#testGetOperationalPlugins, but	 with
	 all the plugins enabled, so the media controls will include another link besides #self"

	| json |

	json := NeoJSONObject fromString: ( self newJWTAuthorizedClient get: self operationsPluginsUrl ).

	self
		assert: json items isCollection;
		assert: json links size equals: 1.

	json items select: [ :plugin | plugin status = 'ENABLED' ]
		thenDo: [ :plugin | self assert: plugin links size equals: 2 ]
]
