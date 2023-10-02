# Application Information

One of the operational plugins. It exposes information about the running application.

This plugin is disabled by default and allows configuring the available
information providers. This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'application-info'
      put: {
        #enabled -> true.
        #'info-providers' -> #('application')} asDictionary;
      yourself
    );
  yourself
```

Available information providers:

- `application` Reports the application name, description, and version
- `gs64` Reports information about the Gem, Shared Page Cache and Stone
- `pharo` Reports information about the Pharo image and VM
- `os` Reports information about the underlying operating system

## API

### Getting info

- Endpoint: `/application-info`
- Allowed HTTP methods: `GET`
- Supported media types:
  - `application/vnd.stargate.operational-application-info+json`
- Authentication: Required
- Authorization: Requires `read:application-info`
- Expected Responses:
  - `200 OK`

Example response:

```json
HTTP/1.1 200 OK
...
Content-Type: application/vnd.stargate.operational-application-info+json;version=1.0.0

{
  "pharo": {
    "image": {
      "version": "7.0.4",
      "build-info": 168,
      "build-commit": "ccd1f6489120f58ddeacb2cac77cd3a0f0dcfbe6",
      "command-line-parameters": [],
      "location": "Pharo.image"
    },
    "vm": {
      "version": "CoInterpreter VMMaker.oscog-eem.2504
      uuid: a00b0fad-c04c-47a6-8a11-5dbff110ac11 Jan  5 2019
      StackToRegisterMappingCogit VMMaker.oscog-eem.2504
      uuid: a00b0fad-c04c-47a6-8a11-5dbff110ac11 Jan  5 2019
      VM: 201901051900 https://github.com/OpenSmalltalk/opensmalltalk-vm.git
      Date: Sat Jan 5 20:00:11 2019 CommitHash: 7a3c6b64 Plugins: 201901051900 https://github.com/OpenSmalltalk/opensmalltalk-vm.git",
      "architecture": "64 bits",
      "image-version-format": 68021,
      "location": "pharo-vm/lib/pharo/5.0-201901051900/pharo",
      "options": [],
      "modules": {
        "loaded": [
          "B2DPlugin VMMaker.oscog-eem.2480 (i)",
          "BitBltPlugin VMMaker.oscog-eem.2493 (i)",
          "DSAPrims CryptographyPlugins-eem.14 (i)",
          "FilePlugin VMMaker.oscog-eem.2498 (i)",
          "FloatArrayPlugin VMMaker.oscog-eem.2480 (i)",
          "IA32ABI VMMaker.oscog-eem.2480 (i)",
          "JPEGReadWriter2Plugin VMMaker.oscog-eem.2493 (e)",
          "LargeIntegers v2.0 VMMaker.oscog-eem.2495 (i)",
          "LocalePlugin VMMaker.oscog-eem.2495 (i)",
          "Matrix2x3Plugin VMMaker.oscog-eem.2480 (i)",
          "MiscPrimitivePlugin VMMaker.oscog-eem.2480 (i)",
          "SecurityPlugin VMMaker.oscog-eem.2480 (i)",
          "SocketPlugin VMMaker.oscog-eem.2495 (i)",
          "SqueakFFIPrims",
          "SqueakSSL VMMaker.oscog-eem.2480 (e)",
          "SurfacePlugin Jan  5 2019 (e)",
          "ZipPlugin VMMaker.oscog-eem.2480 (i)",
          "libc.so.6",
          "libfreetype.so.6",
          "libgit2.so"
        ],
        "built-in": [
          "ADPCMCodecPlugin VMMaker.oscog-eem.2480 (i)",
          "AsynchFilePlugin VMMaker.oscog-eem.2493 (i)",
          "B2DPlugin VMMaker.oscog-eem.2480 (i)",
          "BMPReadWriterPlugin VMMaker.oscog-eem.2480 (i)",
          "BitBltPlugin VMMaker.oscog-eem.2493 (i)",
          "CroquetPlugin VMMaker.oscog-eem.2480 (i)",
          "DSAPrims CryptographyPlugins-eem.14 (i)",
          "DropPlugin VMMaker.oscog-eem.2480 (i)",
          "FFTPlugin VMMaker.oscog-eem.2480 (i)",
          "FileCopyPlugin VMMaker.oscog-eem.2493 (i)",
          "FilePlugin VMMaker.oscog-eem.2498 (i)",
          "FloatArrayPlugin VMMaker.oscog-eem.2480 (i)",
          "FloatMathPlugin VMMaker.oscog-eem.2480 (i)",
          "IA32ABI VMMaker.oscog-eem.2480 (i)",
          "JoystickTabletPlugin VMMaker.oscog-eem.2493 (i)",
          "LargeIntegers v2.0 VMMaker.oscog-eem.2495 (i)",
          "LocalePlugin VMMaker.oscog-eem.2495 (i)",
          "MIDIPlugin VMMaker.oscog-eem.2493 (i)",
          "Matrix2x3Plugin VMMaker.oscog-eem.2480 (i)",
          "MiscPrimitivePlugin VMMaker.oscog-eem.2480 (i)",
          "Mpeg3Plugin VMMaker.oscog-eem.2495 (i)",
          "SecurityPlugin VMMaker.oscog-eem.2480 (i)",
          "SerialPlugin VMMaker.oscog-eem.2493 (i)",
          "SocketPlugin VMMaker.oscog-eem.2495 (i)",
          "SoundCodecPrims VMMaker.oscog-eem.2480 (i)",
          "SoundGenerationPlugin VMMaker.oscog-eem.2480 (i)",
          "SoundPlugin VMMaker.oscog-eem.2495 (i)",
          "SqueakFFIPrims",
          "StarSqueakPlugin VMMaker.oscog-eem.2480 (i)",
          "UnixOSProcessPlugin
          VMConstruction-Plugins-OSProcessPlugin.oscog-eem.61 (i)",
          "VMProfileLinuxSupportPlugin VMMaker.oscog-eem.2480 (i)",
          "ZipPlugin VMMaker.oscog-eem.2480 (i)"
        ]
      },
      "parameters": [
        135890720,
        1825056,
        144842752,
        null,
        null,
        0,
        48,
        4780,
        28236,
        20892,
        9169152,
        0,
        0,
        0,
        0,
        14018700000,
        0,
        2232,
        5135773,
        3751714591267816,
        1262,
        0,
        0,
        33554432,
        16777216,
        2,
        0,
        0,
        0,
        0,
        60,
        40,
        1254,
        145284767072,
        11921,
        80056196,
        0,
        0,
        0,
        8,
        68021,
        50,
        0,
        6854880,
        0,
        1433600,
        0,
        0,
        256,
        null,
        null,
        262144,
        5,
        28692384,
        0.33333298563957214,
        4347898,
        498194,
        10013444,
        2108673,
        22897607,
        6406,
        8400,
        9255,
        2671,
        3,
        8192,
        0,
        38.02421290413667,
        50,
        1,
        15,
        2527,
        0,
        0
      ]
    }
  },
  "os": {
    "general": {
      "platform": "unix",
      "version": "linux-gnu",
      "subtype": "x86_64"
    },
    "details": {
      "version": "Linux version 4.15.0-70-generic (buildd@lgw01-amd64-057)
      (gcc version 5.4.0 20160609
      (Ubuntu 5.4.0-6ubuntu1~16.04.12)) #79~16.04.1-Ubuntu SMP
      Tue Nov 12 14:01:10 UTC 2019",
      "release": {
        "distrib_id": "Ubuntu",
        "distrib_release": "16.04",
        "distrib_codename": "xenial",
        "distrib_description": "Ubuntu 16.04.6 LTS"
      }
    },
    "environment": {
      "LANG": "en_US.UTF-8",
      "LC_MONETARY": "es_AR.UTF-8"
    }
  },
  "application": {
    "name": "Test App",
    "description": "An application for testing purposes",
    "version": "8.9"
  }
}
```
