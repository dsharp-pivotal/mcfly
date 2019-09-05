# Multi-Concourse Fly (mcfly)

*"You're not thinking fourth dimensionally"* -- Doc Brown

*"Please excuse the crudity of this model as I didn't have time to build it to scale or paint it."* -- Doc Brown

Mcfly is for working with multiple Concourse instances that may be at different
versions. Mcfly will determine the version of Concourse on the ATC, and use the
corresponding version of fly. If you don't have that version, it will download
it.

`mcfly` works for all `fly` commands that have a valid `-t <target>` argument.

# Installation

Depends on [yq](http://github.com/mikefarah/yq) and curl.

Recommended installation is to symlink `fly` to `mcfly` in your `PATH`.

```
ln -sf ../workspace/mcfly/mcfly ~/bin/fly
```
