using Capnp
using Documenter

DocMeta.setdocmeta!(Capnp, :DocTestSetup, :(using Capnp); recursive = true)

makedocs(
    modules = [Capnp, Capnp.RPC],
    sitename = "Capnp.jl",
    format = Documenter.HTML(canonical = "https://s-celles.github.io/Capnp.jl", edit_link = "main", prettyurls = get(ENV, "CI", "false") == "true"),
    pages = ["Home" => "index.md", "Supported functionality" => "support.md", "API" => ["Serialization" => "api.md", "RPC types" => "rpc.md", "RPC functions" => "rpc-functions.md"]],
    checkdocs = :exports,
)

deploydocs(repo = "github.com/s-celles/Capnp.jl.git", devbranch = "main")
