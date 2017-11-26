using Pkg3
using Pkg3.Types
if Base.isdeprecated(Main, :Test)
    using Test
else
    using Base.Test
end

using Base.Test
function temp_pkg_dir(fn::Function)
    local project_path
    try
        project_path = joinpath(tempdir(), randstring())
        withenv("JULIA_ENV" => project_path) do
            fn()
        end
    finally
        rm(project_path, recursive=true, force=true)
    end
end

temp_pkg_dir() do
    Pkg3.API.add("Example"; preview = true)
    @test_warn "not in project" Pkg3.API.rm("Example")
    Pkg3.API.add("Example")
    @eval import Example
    Pkg3.API.up()
    Pkg3.API.rm("Example"; preview = true)
    # TODO: Check Example is still considered install
    Pkg3.API.rm("Example")

    try
        Pkg3.API.add([PackageSpec("Example", VersionSpec(v"55"))])
    catch e
        @test contains(sprint(showerror, e), "Example")
    end

    nonexisting_pkg = randstring(14)
    @test_throws CommandError Pkg3.API.add(nonexisting_pkg)
    @test_throws CommandError Pkg3.API.up(nonexisting_pkg)
    @test_warn "not in project" Pkg3.API.rm(nonexisting_pkg)
end

