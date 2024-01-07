# Telco

Dynamic instrumentation toolkit for developers, reverse-engineers, and security
researchers. Learn more at [telco.re](https://telco.re/).

Two ways to install
===================

## 1. Install from prebuilt binaries

This is the recommended way to get started. All you need to do is:

    pip install telco-tools # CLI tools
    pip install telco       # Python bindings
    npm install telco       # Node.js bindings

You may also download pre-built binaries for various operating systems from
Telco's [releases](https://github.com/yunsiong/telco/releases) page on GitHub.

## 2. Build your own binaries

### Dependencies

For running the Telco CLI tools, e.g. `telco`, `telco-ls-devices`, `telco-ps`,
`telco-kill`, `telco-trace`, `telco-discover`, etc., you need Python plus a
few packages:

    pip install colorama prompt-toolkit pygments

### Linux

    make

### Apple OSes

First make a trusted code-signing certificate. You can use the guide at
https://sourceware.org/gdb/wiki/PermissionsDarwin in the sections
“Create a certificate in the System Keychain” and “Trust the certificate
for code signing”. You can use the name `telco-cert` instead of `gdb-cert`
if you'd like.

Next export the name of the created certificate to relevant environment
variables, and run `make`:

    export MACOS_CERTID=telco-cert
    export IOS_CERTID=telco-cert
    export WATCHOS_CERTID=telco-cert
    export TVOS_CERTID=telco-cert
    make

To ensure that macOS accepts the newly created certificate, restart the
`taskgated` daemon:

    sudo killall taskgated

### Windows

    telco.sln

(Requires Visual Studio 2022.)

See [https://telco.re/docs/building/](https://telco.re/docs/building/)
for details.

## Learn more

Have a look at our [documentation](https://telco.re/docs/home/).
