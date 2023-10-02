"
I'm a provider of information about the Pharo version running this application
"
Class {
	#name : #PharoInformationProvider,
	#superclass : #ApplicationInformationProvider,
	#category : #'Stargate-Application-Info-Pharo'
}

{ #category : #accessing }
PharoInformationProvider class >> providerName [

	^ 'pharo'
]

{ #category : #querying }
PharoInformationProvider >> gatherInformation [

	^ Dictionary new
		at: 'image' put: self pharoImageInfo;
		at: 'vm' put: self pharoVirtualMachineInfo;
		yourself
]

{ #category : #private }
PharoInformationProvider >> imageCommandLineParameters [

	^ Smalltalk commandLine arguments
]

{ #category : #private }
PharoInformationProvider >> pharoImageInfo [

	^ OrderedDictionary new
		at: 'version' put: SystemVersion current dottedMajorMinorPatch;
		at: 'build-info' put: SystemVersion current build;
		at: 'build-commit' put: SystemVersion current commitHash;
		at: 'command-line-parameters' put: self imageCommandLineParameters;
		at: 'location' put: Smalltalk image imagePath;
		yourself
]

{ #category : #private }
PharoInformationProvider >> pharoVirtualMachineInfo [

	^ OrderedDictionary new
		at: 'version' put: Smalltalk vm version;
		at: 'architecture' put: ( Smalltalk vm for32bit: [ '32 bits' ] for64bit: [ '64 bits' ] );
		at: 'image-version-format' put: Smalltalk vm imageVersionNumber;
		at: 'location' put: Smalltalk vm vmFileName;
		at: 'options' put: Smalltalk vm options;
		at: 'modules' put: self virtualMachineModules;
		at: 'parameters' put: self virtualMachineParameters;
		yourself
]

{ #category : #private }
PharoInformationProvider >> virtualMachineModules [

	^ OrderedDictionary new
		at: 'loaded' put: Smalltalk vm listLoadedModules sorted;
		at: 'built-in' put: Smalltalk vm listBuiltinModules sorted;
		yourself
]

{ #category : #private }
PharoInformationProvider >> virtualMachineParameters [

	^ Smalltalk vm getParameters
]
