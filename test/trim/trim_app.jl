module TrimApp

using Capnp
using Capnp.RPC
using Sockets

Base.@ccallable function julia_main()::Cint
    try
        println("TrimApp starting")
        return 0
    catch
        return 1
    end
end

end
