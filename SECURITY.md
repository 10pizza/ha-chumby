# Security Policy

This project is not ready for production use.

## Supported Versions

No released versions are currently supported.

## Reporting Security Issues

Open a private security advisory on GitHub when available. If that is not
available, contact the maintainer privately before publishing exploit details.

## Current Security Notes

- SSH access methods documented for stock Chumby firmware may include root login
  without a password.
- Do not expose a Chumby directly to the public internet.
- Do not commit MQTT credentials, Home Assistant tokens, WiFi credentials, or
  firmware signing keys.
- Treat downloaded firmware and update packages as untrusted until verified.
