## Swivel 1.0.0

The first public release of Swivel: convert and edit files on your Mac with a ring menu, right where you drag them.

Drag files in the Finder and hold **⇧** (convert), **⌘** (tools) or **⌃** (actions): a ring appears around the pointer. Drop the
files on an option and the result appears next to the original. Swivel offers 303 conversions and 41 tools, for example HEIC to PNG,
Word to PDF, redacting, signing, OCR and transcription.

Everything stays on your Mac: Swivel has no network access of its own, no telemetry and no update check. Optional helper
programs (FFmpeg, LibreOffice, Ghostscript, qpdf, whisper.cpp, Poppler, unar) are not included; if you install them with Homebrew,
Swivel runs them in a sandbox without internet.

### Requirements

- macOS 26 or later
- A Mac with Apple silicon (M1 or later)

### Installation

1. Download `Swivel-1.0.0.dmg` below, open it and drag **Swivel** into **Applications**.
2. Swivel is not notarized by Apple. The first time you open it, macOS warns you: click **Done**, then go to **System Settings ›
   Privacy & Security** and click **Open Anyway**.

Step-by-step guide, helper programs and the speech model for transcription:
[docs/INSTALLATION.md](https://github.com/jonasnlt/swivel/blob/main/docs/INSTALLATION.md).

### Checksums

`SHA256SUMS.txt` contains the SHA-256 checksums of the DMG and the ZIP:

```
afd8227fa15a9928afac31bae467c5fa5ebe01ad88df5b9d7ed5c2abff0d6909  Swivel-1.0.0.zip
27d318295bb18495fc73eda7109fe192d2d4c7d80e02f9337dcc0b0320e55f8e  Swivel-1.0.0.dmg
```

Check a download in Terminal with `shasum -a 256 Swivel-1.0.0.dmg`.

### Feedback

Found a bug? Open an [issue](https://github.com/jonasnlt/swivel/issues). Please report security problems privately
(see [SECURITY.md](https://github.com/jonasnlt/swivel/blob/main/SECURITY.md)).

Swivel is free software under the GPL-3.0.
