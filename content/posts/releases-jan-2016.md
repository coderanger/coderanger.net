---
title: Releases for January 2016
date: 2016-01-14
---

I've put up a big burst of new cookbooks so I wanted to give everyone a quick
overview of the highlights:


## [`application` 5.1.0](https://github.com/poise/application)

* New resources `application_cookbook_file`, `application_file`, and
  `application_template`.

## [`monit` 1.0.0](https://github.com/poise/poise-monit-compat)

* Major release, converted to a wrapper for `poise-monit`.

## [`poise` 2.5.0](https://github.com/poise/poise)

* New property for inversion resources: `provider_no_auto`. Set one or more
  provider names that will be ignored for automatic resolution for that instance.
* Support `variables` as an alias for `options` in template content properties
  to match the `template` resource.
* New helper: `poise_shell_out`. Like normal `shell_out` but sets group and
  environment variables automatically to better defaults.

## [`poise-javascript` 1.0.1](https://github.com/poise/poise-javascript)

* Update for Chef 12.6 compatibility.
* Update version list for `nodejs` provider.

## [`poise-languages` 1.3.1](https://github.com/poise/poise-languages)

* Fix system package installs on OS X.
* `%{machine_label}` is available in URL template for static download.
* Automatically retry `remote_file` downloads to handle transient HTTP failures.
* All `*_shell_out` language command helpers use `poise_shell_out` to set `$HOME`
  and other environment variables by default.

## [`poise-monit` 1.0.1](https://github.com/poise/poise-monit)

* The initial release and a quick bug fix.

## [`poise-python` 1.2.0](https://github.com/poise/poise-python)

* Add support for passing `user` and `group` to `pip_requirements`.
* Allow passing a virtualenv resource object to the `virtualenv` property.
* Update PyPy release versions.
* Make the `python_virtualenv` resource check for `./bin/python` for idempotence
  instead of the base path.
* Support for packages with extras in `python_package`.
* Support for point releases (7.1, 8.1, etc) of Debian in the `system` provider.

## [`poise-service` 1.1.0](https://github.com/poise/poise-service)

* Added `inittab` provider to manage services using old-fashioned `/etc/inittab`.
* Set GID correctly in all service providers.
* Allow overriding the path to the generated sysvinit script.

## [`poise-service-monit` 1.0.0](https://github.com/poise/poise-service-monit)

* Initial release.

## [`poise-service-runit` 1.1.0](https://github.com/poise/poise-service-runit)

* Support for version 1.7 of the `runit` cookbook.


