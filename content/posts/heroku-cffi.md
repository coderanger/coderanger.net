---
title: Heroku and CFFI
date: 2014-07-22
hire_me: Looking for help with Python development or operations? Check out my <a href="/training/">training</a> and <a href="/consulting/">consulting</a> services.
---


**UPDATE: This is no longer needed, the Python buildpack will install libffi for
you if `cffi` or `cryptography` is present in your requirements.txt.**

[CFFI](https://cffi.readthedocs.org/) is a popular Python library to call C code
from Python. Some major libraries that depend on it include:

* [Cryptography](https://cryptography.io/)
* [bcrypt](https://github.com/pyca/bcrypt)
* [psycopg2cffi](https://github.com/chtd/psycopg2cffi)
* [PyNaCl](https://pynacl.readthedocs.org/)

[buildpack-cffi](https://github.com/coderanger/heroku-buildpack-cffi) allows any
of these libraries to be installed and used in Heroku applications.

# Usage

First set your `BUILDPACK_URL` to `https://github.com/ddollar/heroku-buildpack-multi.git`:

```bash
$ heroku config:set BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
```

Create the `.buildpacks` config for buildpack-multi:

```bash
$ cat .buildpacks
https://github.com/ddollar/heroku-buildpack-apt
https://github.com/coderanger/heroku-buildpack-cffi
https://github.com/heroku/heroku-buildpack-python
```

And then create the `Aptfile` config for buildpack-apt:

```bash
$ cat Aptfile
libffi-dev
```

Then just put the Python libraries you need in the normal requirements.txt.

If you are installing Cryptography, no additional configuration should be
required.
