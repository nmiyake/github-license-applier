# github-license-applier
Downloads the LICENSE file of the specified license type from GitHub.com's license
API and optionally creates a commit that applies it to a Git repository.

Supports the following licenses (alias name in parenthesis):

  * agpl-3.0 (agpl)
  * apache-2.0 (apache)
  * bsd-2-clause (bsd-2)
  * bsd-3-clause (bsd-3)
  * gpl-3.0 (gpl)
  * lgpl-3.0 (lgpl)
  * mit
  * mpl-2.0 (mpl)
  * unlicense

The script stores the SHA-256 digests of the expected content of the license file
and compares the downloaded license to that digest.

## Usage

```bash
./licenser.sh [license-type]
```

Downloads the specified license and writes it to a LICENSE file in the working
directory.

```bash
./licenser.sh -c [license-type]
```

Downloads the specified license and writes it to a LICENSE file in the working
directory and creates a commit that commits the LICENSE file to the repository.

## Requirements

* `jq` to get the license text from the GitHub.com API JSON response
* `openssl`, `shasum` or `sha256sum` to compute the checksum of the license
