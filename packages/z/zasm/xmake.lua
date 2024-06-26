package("zasm")

    set_homepage("https://github.com/GraftMC/zasm-static")
    set_description("x86-64 Assembler based on Zydis")

    set_urls("https://github.com/GraftMC/zasm-static.git")
    add_versions("2024-06-01", "f3af9c90d6f6a3a6909a7eacab0fda5f69cefe23")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("zydis v4.0.0")

    on_install("windows", "macosx", "linux", "bsd", "cross", "mingw", "android", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("zydis v4.0.0")
            target("zasm")
                set_kind("$(kind)")
                set_languages("c++17")
                add_files("src/zasm/**.cpp")
                add_includedirs("include", "src/zasm/src")
                add_headerfiles("include/(**.hpp)")
                if is_plat("windows") then
                    add_cxxflags("/bigobj", "/MP", "/W3", "/permissive-")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
                add_packages("zydis")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <zasm/serialization/serializer.hpp>
            #include <zasm/zasm.hpp>
            using namespace zasm;
            void test() {
                Program program(MachineMode::AMD64);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
