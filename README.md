# Dockerize

[![Build Status](https://travis-ci.org/modcloth-labs/dockerize.png?branch=master)](https://travis-ci.org/modcloth-labs/dockerize)

Dockerizes your project.

## About

Dockerize helps 'dockerize' your application by providing you an easy
way to add Docker integration to your project.  Once a project has been
'dockerized,' you will have some useful files in place that will guide
you through the process of deploying your application with Docker.

## Installation

Install with:

```bash
> gem install dockerize
```

## Usage

The simplest use case is dockerizing the current project.  Example

```bash
> dockerize .
```

Dockerize is also very configurable, and allows many options to be set
through the command line.

To see what options are available, run `dockerize` with the help flag:

```bash
> dockerize --help

# Usage: dockerize <project directory> [options]
# Options:
#                 --quiet, -q:   Silence output
#               --dry-run, -d:   Dry run, do not write any files
#                 --force, -f:   Force existing files to be overwritten
#   --backup, --no-backup, -b:   Creates .bak version of files before overwriting them
#          --registry, -r <s>:   The Docker registry to use when writing files
#      --template-dir, -t <s>:   The directory containing the templates to be written
#        --maintainer, -m <s>:   The default MAINTAINERto use for any Dockerfiles written 
#              --from, -F <s>:   The default FROM to use for any Dockerfiles written
#               --version, -v:   Print version and exit
#                  --help, -h:   Show this message
```

If you want to use `dockerize` to dockerize multiple projects, it may be
useful to set some defaults in the environment.  Options currently
configurable in the environment include:

* default registry - `DOCKERIZE_REGISTRY`
* template dir - `DOCKERIZE_TEMPLATE_DIR`
* default maintainer - `DOCKERIZE_MAINTAINER`
* default base image - `DOCKERIZE_FROM`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
