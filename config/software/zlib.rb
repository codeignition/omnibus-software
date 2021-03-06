#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

name "zlib"
version "1.2.6"

dependency "libgcc"

# TODO: this link is subject to change with each new release of zlib.
#       we'll need to use a more robust link (sourceforge) that will
#       not change over time.
source :url => "http://downloads.sourceforge.net/project/libpng/zlib/1.2.6/zlib-1.2.6.tar.gz",
       :md5 => "618e944d7c7cd6521551e30b32322f4a"

relative_path "zlib-1.2.6"
configure_env =
  case platform
  when "aix"
    {
      "LDFLAGS" => "-maix64 -L#{install_dir}/embedded/lib -Wl,-blibpath:#{install_dir}/embedded/lib:/usr/lib:/lib",
      "CFLAGS" => "-maix64 -I#{install_dir}/embedded/include",
      "LD" => "ld -b64",
      "OBJECT_MODE" => "64",
      "ARFLAGS" => "-X64 cru "
    }
  when "mac_os_x"
    {
      "LDFLAGS" => "-R#{install_dir}/embedded/lib -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
      "CFLAGS" => "-I#{install_dir}/embedded/include -L#{install_dir}/embedded/lib"
    }
  when "solaris2"
    if Omnibus.config.solaris_compiler == "studio"
    {
      "LDFLAGS" => "-R#{install_dir}/embedded/lib -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include -static-libgcc",
      "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include -DNO_VIZ"
    }
    elsif Omnibus.config.solaris_compiler == "gcc"
    {
      "LDFLAGS" => "-R#{install_dir}/embedded/lib -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
      "CFLAGS" => "-I#{install_dir}/embedded/include -L#{install_dir}/embedded/lib -DNO_VIZ"
    }
    else
      raise "Sorry, #{Omnibus.config.solaris_compiler} is not a valid compiler selection."
    end
  else
    {
      "LDFLAGS" => "-Wl,-rpath #{install_dir}/embedded/lib -L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
      "CFLAGS" => "-I#{install_dir}/embedded/include -L#{install_dir}/embedded/lib"
    }
  end

build do
  command "./configure --prefix=#{install_dir}/embedded", :env => configure_env
  command "make -j #{max_build_jobs}"
  command "make -j #{max_build_jobs} install"
end
