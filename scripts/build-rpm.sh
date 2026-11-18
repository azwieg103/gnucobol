#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
WORK="$ROOT/work"
RPMBUILD="$ROOT/rpmbuild"
DIST="$ROOT/dist"

if [[ ! -d "$UPSTREAM" || ! -f "$UPSTREAM/configure.ac" ]]; then
  echo "ERROR: upstream/ is missing or does not contain configure.ac." >&2
  echo "Run the SourceForge sync workflow first." >&2
  exit 1
fi

for cmd in gcc make autoconf automake libtool rpmbuild tar; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: required build command not found: $cmd" >&2
    exit 1
  }
done

rm -rf "$WORK" "$RPMBUILD" "$DIST"
mkdir -p "$WORK/gnucobol" "$RPMBUILD/BUILD" "$RPMBUILD/BUILDROOT" \
  "$RPMBUILD/RPMS" "$RPMBUILD/SOURCES" "$RPMBUILD/SPECS" \
  "$RPMBUILD/SRPMS" "$DIST"
cp -a "$UPSTREAM/." "$WORK/gnucobol/"

cd "$WORK/gnucobol"

# SourceForge's version-control export intentionally omits generated autotools files.
if [[ -x ./autogen.sh ]]; then
  ./autogen.sh
elif [[ -x ./build_aux/bootstrap ]]; then
  ./build_aux/bootstrap
else
  echo "ERROR: upstream source has neither autogen.sh nor build_aux/bootstrap." >&2
  exit 1
fi

VERSION="$(sed -n '/^AC_INIT(\[GnuCOBOL\],/{n;s/^[[:space:]]*\[\([^]]*\)\].*/\1/p;}' configure.ac | head -n1)"
if [[ -z "$VERSION" ]]; then
  echo "ERROR: could not extract upstream version from configure.ac." >&2
  grep -n 'AC_INIT' configure.ac >&2 || true
  exit 1
fi

# RPM Version fields cannot contain hyphens. Preserve the upstream numeric
# version and append the ZWIEGNET rebuild number supplied by CI. Local builds
# default to .1; CI selects the next number from published releases.
RPM_VERSION="${VERSION%%-*}"
RPM_RELEASE="${RPM_RELEASE:-ZWIEGNET.1}"
if [[ ! "$RPM_RELEASE" =~ ^ZWIEGNET\.[1-9][0-9]*$ ]]; then
  echo "ERROR: invalid RPM_RELEASE '$RPM_RELEASE' (expected ZWIEGNET.N)." >&2
  exit 1
fi

echo "Upstream version: $VERSION"
echo "RPM version-release: $RPM_VERSION-$RPM_RELEASE"
tar -czf "$RPMBUILD/SOURCES/gnucobol-$RPM_VERSION.tar.gz" -C "$WORK" gnucobol

rpmbuild -ba "$ROOT/packaging/gnucobol.spec" \
  --define "_topdir $RPMBUILD" \
  --define "gnucobol_version $RPM_VERSION" \
  --define "gnucobol_release $RPM_RELEASE"

find "$RPMBUILD/RPMS" -type f -name '*.rpm' -exec cp -v {} "$DIST/" \;
find "$RPMBUILD/SRPMS" -type f -name '*.src.rpm' -exec cp -v {} "$DIST/" \;

echo
echo "RPM build complete:"
find "$DIST" -maxdepth 1 -type f -printf '%f\n' | sort
