{stdenv
,autoPatchelfHook
,unzipNLS
,makeWrapper
,fetchurl
,writeShellScript
,coreutils
,lib}:
let moonbitComponents = {
    "moon" = fetchurl {
        url = "https://web.archive.org/web/20240308125010if_/https://cli.moonbitlang.com/ubuntu_x86/moon";
        sha256 = "1hjn4019xa8xwysp8yh2n9iqll9304j4h8cx2bh8xhp0acjj6l8v";
    };
    "moonrun" = fetchurl {
        url = "https://web.archive.org/web/20240308125537if_/https://cli.moonbitlang.com/ubuntu_x86/moonrun";
        sha256 = "0w9x4fqql29d5p3miirha9m3cx2j8g6xdhm0sdibplm65ckmrf2b";
    };
    "moonfmt" = fetchurl {
        url = "https://web.archive.org/web/20240308125555if_/https://cli.moonbitlang.com/ubuntu_x86/moonfmt";
        sha256 = "1ynhrsfpn4h3rrbfp8gplr61s2nb6z1nmkjha4wv2wqnplfi4iza";
    };
    "moonc" = fetchurl {
        url = "https://web.archive.org/web/20240308125716if_/https://cli.moonbitlang.com/ubuntu_x86/moonc";
        sha256 = "115v4yi31n9qpcd1rzhvziq38fa8xi4wfxdkwl9rgmvwa7kr2qs1";
    };
    "moondoc" = fetchurl {
        url = "https://web.archive.org/web/20240308125506if_/https://cli.moonbitlang.com/ubuntu_x86/moondoc";
        sha256 = "0yx9jxrxwqrzz0m91wjp2dj3p71zficfn2hskf6magnaz0w3gzy1";
    };
    "moonbit-init" = let moonbitCore = fetchurl {
        url = "https://web.archive.org/web/20240308130719if_/https://cli.moonbitlang.com/core.zip";
        sha256 = "0y59d3iln30979qyfmagaak51n6l3sg1mhxi54g21whds0gb8saf";
    }; in writeShellScript "moon-init" ''
        echo "Unpacking MoonBit core..."
        mkdir -p $HOME/.moon/lib
        cd $HOME/.moon/lib
        rm -rf core
        unzip -qq ${moonbitCore}
        cd core || exit 1
        moon bundle
        echo "MoonBit core updated."
    '';
};
in
stdenv.mkDerivation {
    name = "moonbit";
    version = "20240308";
    buildInputs = [stdenv.cc.cc.lib];
    nativeBuildInputs = [autoPatchelfHook unzipNLS makeWrapper];
    unpackPhase = "true";
    mbComponents = builtins.attrNames moonbitComponents;
    installPhase= ''
      runHook preInstall
      mkdir -p $out/bin
      ${builtins.toString (builtins.attrValues (builtins.mapAttrs (name: value: "cp ${value} $out/bin/${name}; chmod 777 $out/bin/${name};") moonbitComponents))}
      runHook postInstall
    '';
    fixupPhase = ''
      runHook preFixup;
      runHook postFixup;
      for x in $mbComponents; do
          echo $x
          wrapProgram "$out/bin/$x" --set PATH ${lib.makeBinPath [ unzipNLS coreutils ]}:$out/bin
      done
    '';
}
