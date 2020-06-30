#
# Copyright 2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "rest-client"
default_version "v1.8.0"

license "MIT"
license_file "https://github.com/rest-client/rest-client/blob/master/LICENSE"

source git: "https://github.com/rest-client/rest-client.git"

dependency "ruby"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "install --without development test", env: env

  gem "build rest-client.gemspec", env: env
  gem "install rest-client-*.gem", env: env
end
