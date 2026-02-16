# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0]:

- Upgrade to SatochipSwift v0.3.3.
- Add support for Satodime v0.2+:
    - Support for NDEF
    - Simplify ownership management for cards with fixed CVC. For card with fixed CVC, ownership can be taken automatically when ownership is available (setup not done) without prompting user. IF user is not owner on the device, ownership can be taken whenever needed by prompting user for the CVC code written on the card.
    - Added new UnlockCodeDialog for prompting user
- Patch some errors

## [0.2.5]:

- Upgrade to SwiftCryptoTools v0.4.0 (simplified API)
- Fix some issues:
    - Ownership tricky problem on the mobile app when you hit the "Transfert card" button on the desktop app
    - Onboarding screens are shown everytime the app is open.

## [0.2.4]:

- Use SatochipSwift v0.2.0
- Add Paybis integration

## [0.2.3]:

- add Polygon network
- add NFT preview popup
- improved translations & error messages
- various UI improvements
