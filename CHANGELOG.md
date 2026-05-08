# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-05-07

### Added
- Initial release of Kinesis Data Streams module
- Support for multiple streams via `for_each` pattern
- On-demand and provisioned capacity modes
- Server-side encryption with KMS (mandatory)
- Configurable retention period (24-8760 hours)
- Enhanced monitoring with shard-level metrics
- Stream mode configuration
- Additional tags support per stream

### Security
- Encryption at rest enabled by default (PC-IAC-020)
- KMS key ARN required for all streams
