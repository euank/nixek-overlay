# Based on the sway one
{ lib
, vivarium-unwrapped
, makeWrapper, symlinkJoin, writeShellScriptBin
, withBaseWrapper ? true, extraSessionCommands ? "", dbus
, withGtkWrapper ? false, wrapGAppsHook, gdk-pixbuf, glib, gtk3
, extraOptions ? []
}:

assert extraSessionCommands != "" -> withBaseWrapper;

with lib;

let
  desktopEntry = ./vivarium.desktop;
  baseWrapper = writeShellScriptBin "vivarium" ''
     set -o errexit
     if [ ! "$_VIVARIUM_WRAPPER_ALREADY_EXECUTED" ]; then
       ${extraSessionCommands}
       export _VIVARIUM_WRAPPER_ALREADY_EXECUTED=1
     fi
     if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
       export DBUS_SESSION_BUS_ADDRESS
       exec ${vivarium-unwrapped}/bin/vivarium "$@"
     else
       exec ${dbus}/bin/dbus-run-session ${vivarium-unwrapped}/bin/vivarium "$@"
     fi
   '';
in symlinkJoin {
  name = "vivarium-${vivarium-unwrapped.version}";

  paths = (optional withBaseWrapper baseWrapper)
    ++ [ vivarium-unwrapped ];

  nativeBuildInputs = [ makeWrapper ]
    ++ (optional withGtkWrapper wrapGAppsHook);

  buildInputs = optionals withGtkWrapper [ gdk-pixbuf glib gtk3 ];

  # We want to run wrapProgram manually
  dontWrapGApps = true;

  postBuild = ''
    ${optionalString withGtkWrapper "gappsWrapperArgsHook"}

    wrapProgram $out/bin/vivarium \
      ${optionalString withGtkWrapper ''"''${gappsWrapperArgs[@]}"''} \
      ${optionalString (extraOptions != []) "${concatMapStrings (x: " --add-flags " + x) extraOptions}"}
    mkdir -p $out/share/wayland-sessions
    cp ${desktopEntry} $out/share/wayland-sessions/vivarium.desktop
  '';

  passthru.providedSessions = [ "vivarium" ];

  inherit (vivarium-unwrapped) meta;
}
