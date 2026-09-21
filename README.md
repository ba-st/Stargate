# Stargate

![Stargate logo](assets/logo.svg)

Stargate is a library supporting the creation of HTTP based RESTful APIs in
Pharo and GemStone/64. It's built on top of Teapot and Zinc, providing a
conceptual framework to simplify the creation of RESTful APIs including:

- HATEOAS
- Content negotiation
- API versioning
- ETags
- Pagination
- Operations

[![Pharo Unit Tests](https://github.com/ba-st/Stargate/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/unit-tests.yml)
[![GS64 - Unit Tests](https://github.com/ba-st/Stargate/actions/workflows/unit-tests-gs64.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/unit-tests-gs64.yml)
[![Coverage Status](https://codecov.io/github/ba-st/Stargate/coverage.svg?branch=release-candidate)](https://codecov.io/gh/ba-st/Stargate/branch/release-candidate)

[![Baseline Groups](https://github.com/ba-st/Stargate/actions/workflows/loading-groups.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/loading-groups.yml)
[![GS64 Components](https://github.com/ba-st/Stargate/actions/workflows/loading-gs64-components.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/loading-gs64-components.yml)
[![Markdown Lint](https://github.com/ba-st/Stargate/actions/workflows/markdown-lint.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/markdown-lint.yml)
[![Shellcheck](https://github.com/ba-st/Stargate/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ba-st/Stargate/actions/workflows/shellcheck.yml)

[![GitHub release](https://img.shields.io/github/release/ba-st/Stargate.svg)](https://github.com/ba-st/Stargate/releases/latest)

[![Pharo 11](https://img.shields.io/badge/Pharo-11-informational)](https://pharo.org)
[![Pharo 12](https://img.shields.io/badge/Pharo-12-informational)](https://pharo.org)
[![Pharo 13](https://img.shields.io/badge/Pharo-13-informational)](https://pharo.org)

[![GS64 3.7.1](https://img.shields.io/badge/GS64-3.7.1-informational)](https://gemtalksystems.com/products/gs64/)

## Quick links

- [**Explore the docs**](docs/README.md)
- [Report a defect](https://github.com/ba-st/Stargate/issues/new?labels=Type%3A+Defect)
- [Request a feature](https://github.com/ba-st/Stargate/issues/new?labels=Type%3A+Feature)

## Example

A controller declares the routes it serves, and how each one is handled:

```smalltalk
declareGetCurrencyRoute

  ^ RouteSpecification
      handling: #GET
      at: self identifierTemplate
      evaluating: [ :httpRequest :requestContext |
        self currencyBasedOn: httpRequest within: requestContext ]
```

An API is the controllers you install, plus the configuration they run with:

```smalltalk
| api |
api := HTTPBasedRESTfulAPI
configuredBy: {
    #port -> 9999.
    #serverUrl -> ('http://localhost' asUrl port: 9999).
    #operations ->
      (Dictionary new
        at: #authSchema put: 'basic';
        at: #authUsername put: 'test';
        at: #authPassword put: 'test';
        yourself )
    }
installing: { SouthAmericanCurrenciesRESTfulController new }.

api
    install;
    start
```

[How to start up an API](docs/how-to/how-to-startup-API.md) explains the
configuration options, and the
[controllers reference](docs/reference/Controllers.md) covers what a controller
can declare.

## Installation

Stargate runs on Pharo 11, 12 and 13, and on GemStone/64 3.7.1.

To load it in a Pharo image evaluate:

```smalltalk
Metacello new
  baseline: 'Stargate';
  repository: 'github://ba-st/Stargate:release-candidate';
  load: 'Development'.
```

> Change `release-candidate` to some released version if you want a pinned
> version

[The loading instructions](docs/how-to/how-to-load-in-pharo.md) cover Iceberg
as well, the [baseline groups reference](docs/reference/Baseline-groups.md) says
which group to load, and
[how to use Stargate as a dependency](docs/how-to/how-to-use-as-dependency-in-pharo.md)
covers declaring it in your own project.

## Contributing

Check the [Contribution Guidelines](CONTRIBUTING.md).

This repository ships a development container carrying a Pharo image and the
tooling the project uses;
[how to develop in the Pharo image](docs/how-to/develop-in-the-pharo-image.md)
covers working in it.

## License

- The code is licensed under [MIT](LICENSE).
- The documentation is licensed under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/).

---
*Icons by [icons8.com](https://icons8.com)*
