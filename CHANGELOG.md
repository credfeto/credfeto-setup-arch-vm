# Changelog
All notable changes to this project will be documented in this file.

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
### Added
- AI instructions for changelog tool and self-documenting rules workflow
### Fixed
- Enable pkgstats.timer via symlink for static unit as it has no [Install] section and cannot be enabled with systemctl enable
### Changed
- Use dotnet changelog invocation instead of direct changelog command to avoid PATH configuration
- Move remembering-new-rules guidance from changelog instructions to .ai-instructions index
- Git workflow instruction to push to origin after committing to an existing branch
- AI instruction to re-read all instructions before starting work on a feature
### Removed
### Deployment Changes

<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->
## [0.0.0] - Project created