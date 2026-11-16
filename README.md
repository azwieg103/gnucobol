# ZWIEGNET GnuCOBOL RPM

This repository tracks the official GnuCOBOL Subversion source and builds
ZWIEGNET RPM packages for AlmaLinux 10 x86_64.

## Upstream source

The source of truth is the official GnuCOBOL project on SourceForge:

- Project: https://sourceforge.net/projects/gnucobol/
- Subversion: https://svn.code.sf.net/p/gnucobol/code
- Tracked branch: \`branches/gnucobol-3.x\`

The 3.x development branch is intentional: GnuCOBOL 4.0 development is a
separate compatibility line and is not silently substituted into this package.
The sync workflow exports the current upstream branch into \`upstream/\` and
records its Subversion revision.

## Automation

- \`sync-upstream.yml\` checks SourceForge every six hours and can be run manually.
- A changed upstream export is committed to \`main\`.
- \`build-rpm.yml\` runs after upstream source changes, builds and tests in AlmaLinux
  10, and uploads the RPM as a workflow artifact.
- RPM publication as a GitHub Release is a separate, deliberate step; failed
  builds and tests do not publish packages.

## Package policy

- Package name: \`gnucobol\`
- RPM version: extracted from upstream \`configure.ac\`
- RPM release: \`ZWIEGNET.1\`
- Architecture: \`x86_64\`
- No Berkeley DB development dependency is installed in the build environment.
  Indexed-file/DB support is therefore not enabled through Berkeley DB.
- Database client integrations such as PostgreSQL are application build
  dependencies, not compiler-package dependencies.

## Local build

On AlmaLinux 10, install the build requirements listed in
\`.github/workflows/build-rpm.yml\`, then run:

\`\`\`bash
bash scripts/build-rpm.sh
\`\`\`

The generated RPMs are placed in \`dist/\`.
