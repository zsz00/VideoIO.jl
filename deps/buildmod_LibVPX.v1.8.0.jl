using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
 # No shared product (or executable) is created on windows (only static), therefore no product to catch
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaIO/LibVPXBuilder/releases/download/v1.8.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/LibVPX.v1.8.0.aarch64-linux-gnu.tar.gz", "0ca53a5d171d131fffc8cae324d8959fd2926b62186d76cba39abcabb9640dd8"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/LibVPX.v1.8.0.aarch64-linux-musl.tar.gz", "c62d742efd6fbd05b6a0df38e6ff9af37171e8269b93fdf1e4bbdbf0056d0855"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/LibVPX.v1.8.0.arm-linux-gnueabihf.tar.gz", "639839fba62820fae3158d0bf0e519b290cf0d4e02b6fb333ce832925e7d6814"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/LibVPX.v1.8.0.arm-linux-musleabihf.tar.gz", "96cc62e55ac02afaae6758fb38dd4a27d7dbfb0099a08684628e7d18a3b737c5"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/LibVPX.v1.8.0.i686-linux-gnu.tar.gz", "43918c8ceb7d4bd83d3a3ba7c6f7f2aa89caa5d87967bd042262056d398bb102"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/LibVPX.v1.8.0.i686-linux-musl.tar.gz", "a75ea3c204ab2561558172de5e61748d288c252ddbade5679ceefb879add71c7"),
    Windows(:i686) => ("$bin_prefix/LibVPX.v1.8.0.i686-w64-mingw32.tar.gz", "24e6e9b7ca4be74c1398fe8233203b8cdbe719eb8593b9eddcd5220ec18f3045"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/LibVPX.v1.8.0.powerpc64le-linux-gnu.tar.gz", "de176a41ed5192e673065a38bf790c07c4e979500b34bf4d6e3869ac26517a46"),
    MacOS(:x86_64) => ("$bin_prefix/LibVPX.v1.8.0.x86_64-apple-darwin14.tar.gz", "ac7a5d52277c2ca2e5d636c260d51d954e28a3327edc8815268f8cd3a2a58f25"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/LibVPX.v1.8.0.x86_64-linux-gnu.tar.gz", "5d512a2376877c94287016929cbc3257ed61928d18717813d30bb8c222f563fa"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/LibVPX.v1.8.0.x86_64-linux-musl.tar.gz", "ac2e63212f250aedbb847fb909def6a12a2d960566ed7287bea88bc140f1ce1c"),
    FreeBSD(:x86_64) => ("$bin_prefix/LibVPX.v1.8.0.x86_64-unknown-freebsd11.1.tar.gz", "1094e4ad1fb5258c77c09e965918954dee3601690aee14d8f5dceeb044c1036b"),
    Windows(:x86_64) => ("$bin_prefix/LibVPX.v1.8.0.x86_64-w64-mingw32.tar.gz", "9ba02c1c11e7f3bdb2b0b2fb1753cfe48101ae8efdbd300eaa69d8feaab23b0c"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = true #FORCE INSTALLATION GIVEN POINT MADE ABOVE IN products 

dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
#write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
