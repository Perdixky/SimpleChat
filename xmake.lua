set_project("ModernChat")
set_version("1.0.0")

add_rules("mode.debug")
set_languages("cxxlatest")

set_toolchains("llvm")

set_exceptions("no-cxx")

-- Debug 模式下启用 AddressSanitizer
-- if is_mode("debug") then
--     set_policy("build.sanitizer.address", true)
--     set_policy("build.sanitizer.undefined", true)
--     set_policy("build.sanitizer.thread", true)
--     set_policy("build.sanitizer.memory", true)
--     set_policy("build.sanitizer.leak", true)
-- end

includes("xmake/xmake.lua")

add_requires("qt6base", "stdexec-git", "libolm", "libquotient", "qtkeychain", "openssl")

target("SimpleChat")
    add_rules("my.qt.quickapp")
    add_files("main.cpp")
    add_files("ModernChat.qrc")
    add_includedirs("include")

    add_packages("qt6base", "stdexec-git", "libolm", "libquotient", "qtkeychain", "openssl")

    -- 平台特定配置
    if is_plat("android") then
        set_kind("shared")
        add_defines("Q_OS_ANDROID")
        add_syslinks("log", "android")
        set_values("qt.android.package_source_dir", "$(projectdir)/android")
    elseif is_plat("windows") then
        set_kind("binary")
        add_links("Qt6EntryPointd")
    end

package("stdexec-git")
  set_kind("library", {headeronly = true})
  set_homepage("https://github.com/NVIDIA/stdexec")
  set_description("`std::execution`, the proposed C++ framework for asynchronous and parallel programming. ")
  set_license("Apache-2.0")

  add_urls("https://github.com/NVIDIA/stdexec.git")

  add_versions("latest", "main")

  set_policy("package.cmake_generator.ninja", false)

  add_deps("cmake")

  if on_check then
    on_check("windows", function(package)
      import("core.base.semver")

      local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
      assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(stdexec): need vs_toolset >= v143")
    end)
  end

  on_install("windows", "linux", "macosx", "mingw", "msys", function(package)
    if package:has_tool("cxx", "cl") then
      package:add("cxxflags", "/Zc:__cplusplus", "/Zc:preprocessor")
    end

    local configs = { "-DSTDEXEC_BUILD_EXAMPLES=OFF", "-DSTDEXEC_BUILD_TESTS=OFF" }
    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
    table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    import("package.tools.cmake").install(package, configs)
  end)

  on_test(function(package)
    assert(package:has_cxxincludes("stdexec/execution.hpp", { configs = { languages = "c++23" } }))
    -- assert(package:has_cxxincludes("asioexec/use_sender.hpp", { configs = { languages = "c++23" } }))
    -- assert(package:has_cxxincludes("execpools/asio/asio_thread_pool.hpp", { configs = { languages = "c++23" } }))
  end)

package("libolm")
  set_kind("library")
  set_description("An implementation of the Double Ratchet cryptographic ratchet described by https://whispersystems.org/docs/specifications/doubleratchet/, written in C and C++11 and exposed as a C API.")
  set_license("Apache-2.0")

  add_urls("https://gitlab.matrix.org/matrix-org/olm.git")

  add_versions("latest", "master")

  add_deps("cmake")

  on_install("windows", "linux", "macosx", "mingw", "msys", function(package)
    if package:has_tool("cxx", "cl") then
      package:add("cxxflags", "/Zc:__cplusplus", "/Zc:preprocessor")
    end

    local configs = { "-DBUILD_SHARED_LIBS=NO", "-DOLM_TESTS=NO" }
    import("package.tools.cmake").install(package, configs)
  end)

  on_test(function(package)
    assert(package:has_cxxincludes("olm/olm.h", { configs = { languages = "c++23" } }))
  end)

package("libquotient")
  set_kind("library")
  set_homepage("https://quotient-im.github.io/libQuotient/")
  set_description("A Qt library to write cross-platform clients for Matrix")
  set_license("LGPL-2.1-or-later")

  add_urls("https://github.com/quotient-im/libQuotient.git")

  add_versions("latest", "0.9.x")

  add_deps("cmake", "qt6base", "openssl", "libolm", "qtkeychain")

  on_install("windows", "linux", "macosx", function (package)
      local configs = {}
      table.insert(configs, "-DQuotient_INSTALL_TESTS=OFF")
      table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
      table.insert(configs, "-DBUILD_TESTING=OFF")

      package:add("defines", "QUOTIENT_STATIC")  -- 这个宏在静态链接时需要定义

      import("package.tools.cmake").install(package, configs)
  end)

  -- on_test(function(package)
  --   local qt = package:dep("qt6base")
  --   local includedirs = {}
  --   local linkdirs = {}
  --   local links = {}
  --   if qt then
  --       table.insert(includedirs, qt:installdir("include"))
  --       table.insert(includedirs, qt:installdir("include/QtCore"))
  --       table.insert(linkdirs, qt:installdir("lib"))
  --       if package:debug() then
  --           table.insert(links, "Qt6Cored")
  --       else
  --           table.insert(links, "Qt6Core")
  --       end
  --   end
  --   assert(package:has_cxxincludes("Quotient/connection.h", { configs = { languages = "c++23", includedirs = includedirs, linkdirs = linkdirs, links = links } }))
  -- end)

package("qtkeychain")
  set_kind("library")
  set_homepage("https://github.com/frankosterfeld/qtkeychain.git")
  set_description("Qt API to store passwords and other secret data securely")
  set_license("BSD-3-Clause")

  add_urls("https://github.com/frankosterfeld/qtkeychain.git")

  add_versions("latest", "main")

  add_deps("cmake", "qt6base")

  on_install("linux", "macosx", function (package)
      local configs = {}
      table.insert(configs, "-DBUILD_WITH_QT6=ON")
      table.insert(configs, "-DBUILD_TESTING=OFF")

      -- -- 获取 qt6base 包的安装路径
      -- local qt = package:dep("qt6base")
      -- if qt then
      --     local qtdir = qt:installdir()
      --     if qtdir then
      --         table.insert(configs, "-DCMAKE_PREFIX_PATH=" .. qtdir)
      --     end
      -- end

      import("package.tools.cmake").install(package, configs)
  end)

  on_install("windows", function (package)
      local configs = {}
      table.insert(configs, "-DUSE_CREDENTIAL_STORE=OFF")
      table.insert(configs, "-DBUILD_WITH_QT6=ON")
      table.insert(configs, "-DBUILD_TESTING=OFF")
      table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")

      -- -- 获取 qt6base 包的安装路径
      -- local qt = package:dep("qt6base")
      -- if qt then
      --     local qtdir = qt:installdir()
      --     if qtdir then
      --         table.insert(configs, "-DCMAKE_PREFIX_PATH=" .. qtdir)
      --     end
      -- end

      import("package.tools.cmake").install(package, configs)
  end)

  -- on_test(function(package)
  --   local qt = package:dep("qt6base")
  --   local includedirs = {}
  --   local linkdirs = {}
  --   local links = {}
  --   if qt then
  --       table.insert(includedirs, qt:installdir("include"))
  --       table.insert(includedirs, qt:installdir("include/QtCore"))
  --       table.insert(linkdirs, qt:installdir("lib"))
  --       -- debug 模式用 Qt6Cored，release 用 Qt6Core
  --       if package:debug() then
  --           table.insert(links, "Qt6Cored")
  --       else
  --           table.insert(links, "Qt6Core")
  --       end
  --   end
  --   assert(package:has_cxxincludes("qt6keychain/keychain.h", { configs = { languages = "c++23", includedirs = includedirs, linkdirs = linkdirs, links = links } }))
  -- end)
