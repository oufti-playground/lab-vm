
# CHANGELOG

## Version 1.3.0

* External URL tunable with the environment variable `EXTERNAL_URL`,
with the default value "80".
* [Alpine2Docker 1.6.0](https://github.com/dduportal/alpine2docker/releases/tag/1.6.0) (Alpine Linux 3.8, Docker 18.03-CE, )
* Jenkins:
  - LTS 2.121.3
  - Blue Ocean 1.8.5
  - Agent for Java9 changed (and renamed) to Java11
* Gitea:
  - Updated to 1.5.1
* Docker socket container updated  to Alpine 3.8

## Version 1.2.0

* External URL moved from http://localhost:10000 to http://localhost:80
* [Alpine2Docker 1.5.0](https://github.com/dduportal/alpine2docker/releases/tag/1.5.0) (Alpine Linux 3.7, Docker 17.05-CE, )
* Jenkins:
  - LTS 2.121.2
  - Blue Ocean 1.7.1
  - Agent for Java7 changed (and renamed) to Java9
* Gitea:
  - Updated to 1.4.3
  - Using PostegreSQL-10 instead of SQLite for data backend
