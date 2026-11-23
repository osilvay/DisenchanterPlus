"""Build the Forever and TBC distribution archives."""

from fnmatch import fnmatchcase
from io import BytesIO
from pathlib import Path, PurePosixPath
import os
from tempfile import TemporaryDirectory
from urllib.request import urlopen
from zipfile import ZIP_DEFLATED, ZipFile

ROOT = Path(__file__).resolve().parent
ACE3_SOURCE = "https://codeload.github.com/WoWUIDev/Ace3/zip/refs/heads/master"
# AceDB on Forever uses different character keys in newer versions.
ACE3_UI = ("AceGUI-3.0", "AceConfig-3.0")


def fetch_ace3_ui():
    with urlopen(ACE3_SOURCE, timeout=30) as response:
        download = BytesIO(response.read())

    libraries = {}
    with ZipFile(download) as archive:
        for member in archive.infolist():
            parts = PurePosixPath(member.filename).parts
            if not member.is_dir() and len(parts) >= 3 and parts[1] in ACE3_UI:
                path = PurePosixPath("Libs", *parts[1:])
                if ".." in path.parts:
                    raise ValueError(f"Invalid Ace3 archive path: {member.filename}")
                libraries[path] = archive.read(member)

        for library in ACE3_UI:
            if PurePosixPath("Libs", library, f"{library}.xml") not in libraries:
                raise ValueError(f"Missing {library} in the upstream Ace3 archive")

        print(f"Ace3 revision: {archive.comment.decode('ascii')}")
    return libraries


def build_zip(destination, flavor, libraries):
    exclusions = (ROOT / f"packagerExclusions-{flavor}.lst").read_text().splitlines()
    with ZipFile(destination, "w", ZIP_DEFLATED) as archive:
        for directory, dirs, files in os.walk(ROOT):
            directory = Path(directory)
            dirs[:] = sorted(
                name for name in dirs
                if not any(fnmatchcase(name, pattern) for pattern in exclusions)
                and not (directory == ROOT / "Libs" and name in ACE3_UI)
            )
            for name in sorted(files):
                if any(fnmatchcase(name, pattern) for pattern in exclusions):
                    continue
                source = directory / name
                archive.write(source, Path("DisenchanterPlus", source.relative_to(ROOT)))

        for path, contents in libraries.items():
            archive.writestr(str(PurePosixPath("DisenchanterPlus", path)), contents)


def main():
    version = (ROOT / ".version").read_text().strip()
    libraries = fetch_ace3_ui()
    release = ROOT / "Release"
    release.mkdir(exist_ok=True)
    with TemporaryDirectory(dir=release) as staging:
        archives = []
        for flavor in ("Camelot", "TBC"):
            name = f"DisenchanterPlus-v{version}-{flavor.lower()}.zip"
            archive = Path(staging) / name
            build_zip(archive, flavor, libraries)
            archives.append(archive)

        for archive in archives:
            destination = archive.replace(release / archive.name)
            print(f"Package created: {destination}")


if __name__ == "__main__":
    main()
