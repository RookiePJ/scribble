<p align="center">
  <img width="460" height="300" src="static/logo.png">
</p>

[![Build Status](https://drone.infra.mythx.io/api/badges/ConsenSys/scribble/status.svg)](https://drone.infra.mythx.io/ConsenSys/scribble)
[![Coverage](https://codecov.io/gh/ConsenSys/scribble/branch/develop/graph/badge.svg?token=yVZzF90k9k)](https://codecov.io/gh/ConsenSys/scribble)
[![Documentation](https://aleen42.github.io/badges/src/gitbook_2.svg)](https://docs.scribble.codes)
[![npm](https://img.shields.io/npm/v/eth-scribble)](https://www.npmjs.com/package/eth-scribble)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A Solidity runtime verification tool for property based testing.

## Principles and Design Goals

The design of the Scribble specification language takes inspiration from several existing
languages and we expect the language to evolve gradually as we gain more experience
in using it. We rely on the following principles and design goals to guide language
evolution:

1. Specifications are easy to understand by developers and auditors
2. Specifications are simple to reason about
3. Specifications can be efficiently checked using off-the-shelf analysis tools
4. A small number of core specification constructs are sufficient to express and reason about more advanced constructs

We are aware that this will make it difficult or impossible to express certain
properties. We encourage users to reach out if they encounter such properties. However, it
is not our itention to support every property imaginable. We consider it a great success if
Scribble is able to capture 95% of the properties that users _want_ to express.

## Usage

Install Scribble with npm:

```bash
npm install -g eth-scribble
```

Use CLI tool with the Solidity source file:

```bash
scribble sample.sol
```

Use `--help` to see all available features.

## Extension for VS Code

There is a [**Scribble extension for VSCode**](https://marketplace.visualstudio.com/items?itemName=diligence.vscode-scribble) that enhances user experience: prividing syntax highlight, hints-on-hover and other features.

Note that it is maintained in [**separate repostory**](https://github.com/ConsenSys/vscode-scribble). Report extension-related suggestions and issues there.

## Documentation

For more information on the Scribble specification language, and any other documentation, go to: [Scribble Documentation](https://docs.scribble.codes)

## Development installation

### Prerequisites

We suggest to use latest NodeJS LTS release `lts/gallium` (v16.14.0) and associated version of NPM. If there is a need to run different NodeJS versions, consider using [NVM](https://github.com/nvm-sh/nvm) or similar tool, that is available for your platform.

### Clone and build

Clone repository, install and link:

```bash
git clone https://github.com/ConsenSys/scribble.git
cd scribble/
npm install
npm link
```

Prior to running tests the compiler pre-downloading script `download.sh` may be used to setup local compiler cache:

```bash
download.sh 'linux-amd64' '.compiler_cache'  # platform-dependent native compiler builds
download.sh 'wasm' '.compiler_cache'         # cross-platform WASM compiler builds
```
