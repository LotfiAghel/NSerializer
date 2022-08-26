# Package

version       = "0.1.0"
author        = "FTH"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
backend       = "c"

requires "nim >= 1.4.2"
requires "serialization"

from os import `/`, parentDir

task hello, "This is a hello task":
  echo("Hello World!")

before hello:
  echo("About to call hello!")


task test, "Run all tests":
  let common_args = "c -r -f --hints:off --skipParentCfg --styleCheck:usages --styleCheck:error " & getEnv("NIMFLAGS")
  exec "nim " & common_args & " --threads:off tests/test_all"
  exec "nim " & common_args & " --threads:on tests/test_all"


