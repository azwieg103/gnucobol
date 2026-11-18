# ZWIEGNET GnuCOBOL for Enterprise Linux 10

This repository rebuilds GnuCOBOL from the source code maintained in this
GitHub repository and publishes RPM packages intended for Enterprise Linux
10-compatible distributions.

The packages target the following platforms:

- AlmaLinux 10
- Red Hat Enterprise Linux (RHEL) 10
- Oracle Linux 10
- Rocky Linux 10
- CentOS Stream 10

The RPMs are built on AlmaLinux 10 x86_64. They are intended for use across
the Enterprise Linux 10 family, but are not individually built or tested on
every listed distribution. Compatibility may vary by system configuration.

**No warranty or support is provided.** These packages are supplied as-is.
Use them at your own risk; this repository does not provide commercial,
security, or production support.

## Source code and upstream

The RPMs are a rebuild of the GnuCOBOL source code present in this repository
under `upstream/`. That source is synchronized from the official GnuCOBOL
project on SourceForge:

- Project: https://sourceforge.net/projects/gnucobol/
- Subversion: https://svn.code.sf.net/p/gnucobol/code
- Tracked branch: `branches/gnucobol-3.x`

The 3.x development branch is intentional: GnuCOBOL 4.0 development is a
separate compatibility line and is not silently substituted into this package.
The sync workflow exports the current upstream branch into `upstream/` and
records its Subversion revision. The build uses that checked-in GitHub source
snapshot.

## Published packages

Successful builds are published as GitHub Releases in this repository.
Each release includes the binary RPM and source RPM for Enterprise Linux 10
x86_64.

RPM versioning uses the exact upstream numeric version, followed by a
ZWIEGNET rebuild identifier. Upstream suffixes such as `-dev` are omitted
because RPM version fields do not use that suffix. For example, upstream
`3.3-dev` becomes RPM version `3.3`.

The release field uses the format `ZWIEGNET.N.el10`, where `N` is a
per-upstream-version rebuild counter. For this repository's existing GnuCOBOL
3.3 releases, the earlier `ZWIEGNET.1` and `ZWIEGNET.2` builds predate the
EL suffix; the next build is therefore `ZWIEGNET.3.el10`. Subsequent 3.3
rebuilds increment the number (`ZWIEGNET.4.el10`, and so on). New upstream
versions start at `ZWIEGNET.1.el10`. The `.el10` suffix identifies the
Enterprise Linux 10 target. The RPM filename follows this pattern:

`gnucobol-<upstream-version>-ZWIEGNET.<build-number>.el10.x86_64.rpm`

## Automation

- The upstream sync workflow checks SourceForge on its configured schedule
  and can also be run manually.
- A changed upstream export is committed to `main`.
- The RPM workflow builds and tests the source in an AlmaLinux 10 environment.
- Builds are serialized and the next ZWIEGNET number is selected from
  previously published releases for that upstream version.
- RPMs are published to a GitHub Release only after the build and test suite
  complete successfully.

## Package policy

- Package name: `gnucobol`
- Architecture: `x86_64`
- RPM release identifier: `ZWIEGNET.N.el10` (EL10-qualified, incrementing per upstream version)
- Berkeley DB support is disabled; no Berkeley DB development dependency is
  installed in the build environment.
- Database client integrations such as PostgreSQL are application build
  dependencies, not compiler-package dependencies.


## Example: Hello, World!

Create a file named `helloworld.cob`:

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO-WORLD.
       PROCEDURE DIVISION.
           DISPLAY "Hello, World!".
           STOP RUN.
```

Compile it with GnuCOBOL:

```bash
cobc -x helloworld.cob
```

Run the resulting executable:

```bash
./helloworld
```

Expected output:

```text
Hello, World!
```

## Local build

On AlmaLinux 10, install the build requirements listed in
`.github/workflows/build-rpm.yml`, then run:

```bash
bash scripts/build-rpm.sh
```

The generated RPMs are placed in `dist/`. A local build defaults to
`ZWIEGNET.1.el10`; CI supplies the next release number automatically.
