#
# When updating this, check doc/FrequentTasks.md for checklists to ensure all
# the various usages are updated in lockstep
#
override :rabbitmq, version: "3.6.15"
override :erlang, version: "20.3.8.9"
override :lua, version: "5.1.5"
override :rubygems, version: "3.1.2"
#override :bundler, version: "2.1.4"
override :'omnibus-ctl', version: "master"
override :chef, version: "v16.2.50"
override :ohai, version: "v16.2.1"
override :ruby, version: "2.7.1"
override :perl, version: "5.18.1"


# This SHA is the last commit before the 6.0 release
#override :'berkshelf-no-depselector', version: '6016ca10b2f46508b1b107264228668776f505d9'

# Note 2018/02/01 (sr): This is related to issue #1417:
# 1.11.2.1 was the last version that supports --with-lua51=PATH, which allows us to
# build it with lua on ppc64[le] and s390x. Those platforms are not supported
# in mainline luajit. There's forks for ppc64, and s390x, but going forward with
# those was so far blocked by ppc64 not being supported even with the PPC64
# fork.
override :openresty, version: "1.15.8.1"
