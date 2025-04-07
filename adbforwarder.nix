{ lib
, stdenv
, fetchurl
, makeWrapper
, dotnet-runtime
, autoPatchelfHook
, unzip
, zlib
, gcc
, lttng-ust
, icu
, openssl
, android-tools
}:



stdenv.mkDerivation rec {
  pname = "adbforwarder";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/alvr-org/ADBForwarder/releases/download/v1.4/ADBForwarder-linux-x64.zip";
    sha256 = "sha256-3Gqu66RdpHhNebDXLd2TeBx/BwVvUlWPX8yt9qUs2hg=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    dotnet-runtime
    zlib
    gcc
    lttng-ust
    icu
    openssl
    android-tools
  ];
propagatedBuildInputs = [
  icu
  android-tools
];


  # Instruct autoPatchelfHook to ignore missing liblttng-ust.so.0.
  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    unzip $src -d source
    runHook postUnpack
  '';

installPhase = ''
  mkdir -p $out/bin $out/share/adbforwarder
  cp -r source/adbforwarder/* $out/share/adbforwarder/
  chmod +x $out/share/adbforwarder/ADBForwarder
  
  # Create the platform-tools directory that the app expects
  mkdir -p $out/share/adbforwarder/adb/platform-tools
  
  # Link the system adb into the expected location
  ln -sf ${android-tools}/bin/adb $out/share/adbforwarder/adb/platform-tools/adb
  
  # Properly wrap the executable to ensure it finds both system ADB and the linked ADB
  makeWrapper $out/share/adbforwarder/ADBForwarder $out/bin/adbforwarder \
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
    --prefix PATH : ${lib.makeBinPath [ android-tools ]}
'';


meta = with lib; {
    description = "ADB Forwarder";
    homepage = "https://github.com/alvr-org/ADBForwarder";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}

