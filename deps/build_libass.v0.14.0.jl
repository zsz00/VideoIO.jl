using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libass"], :libass),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaIO/LibassBuilder/releases/download/v0.14.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libass.v0.14.0.aarch64-linux-gnu.tar.gz", "e2b9e365e466f2f12b4f53adb89c524428c923676ed70e0ec148b552fc194c55"),
    Linux(:aarch64, :musl) => ("$bin_prefix/libass.v0.14.0.aarch64-linux-musl.tar.gz", "d0b3cf687da4316957ac9014f7d95105b98aecf0acb942a8d5f8adc1f8c9baa5"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/libass.v0.14.0.arm-linux-gnueabihf.tar.gz", "d4bbe1b9cc7b46cfae4081cc1cbf7e3afb5ccd6b3ecb98cdfcc306fc4d91573a"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/libass.v0.14.0.arm-linux-musleabihf.tar.gz", "11f8653990248459a8c290d5a471d3e9867c780759a15eee055d1031c4940fcb"),
    Linux(:i686, :glibc) => ("$bin_prefix/libass.v0.14.0.i686-linux-gnu.tar.gz", "1645b0f37f7b5ff58ca218a8f36ba11e93652eeec7ad0409f219c4567cc662cb"),
    Linux(:i686, :musl) => ("$bin_prefix/libass.v0.14.0.i686-linux-musl.tar.gz", "387d52a6d62bb29fb3ffab820646b2d1baf4c6a8e63ce9a4defbdd5f5e898721"),
    Windows(:i686) => ("$bin_prefix/libass.v0.14.0.i686-w64-mingw32.tar.gz", "3bdf6151c0439a66865676cdcede13cd21cbe09cbc5d4fe9f15cf86d77a08119"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libass.v0.14.0.powerpc64le-linux-gnu.tar.gz", "43cdc5aa00687256b2495e5732c398b8bf149c1b8d21dc0891cda30de9d4508b"),
    MacOS(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-apple-darwin14.tar.gz", "2fb5f032a8956fa771958624972a88675f06510247a58433119616098938dec1"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/libass.v0.14.0.x86_64-linux-gnu.tar.gz", "9a778938f5f1cd9e9d95a193991226fdc4cceaf7723e20c341945f4d69ccacd2"),
    Linux(:x86_64, :musl) => ("$bin_prefix/libass.v0.14.0.x86_64-linux-musl.tar.gz", "56deb14c861cf7a5d32d4d4bda9e814a007d75bcf2e1ef2b6d948999614a622b"),
    FreeBSD(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-unknown-freebsd11.1.tar.gz", "9feefb2c4235f4b8bd8f86bf5921f1be064524e9396ba35245596ef308390fd7"),
    Windows(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-w64-mingw32.tar.gz", "5cf9e260983e1bea3ab717fe8aab2865ed83d6abcb85375fdf6dee1c92119165"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_codec.jl"), products)
