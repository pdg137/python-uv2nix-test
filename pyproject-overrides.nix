# From https://github.com/pyedifice/pyedifice/blob/master/pyproject-overrides.nix
# See
# https://github.com/nix-community/poetry2nix/blob/master/overrides/default.nix
pkgs: # nixpkgs
final: # final python package set
prev: # previous python package set
{
  # https://github.com/nix-community/poetry2nix/blob/1fb01e90771f762655be7e0e805516cd7fa4d58e/overrides/default.nix#L2899
  pyside6-essentials = prev.pyside6-essentials.overrideAttrs (old: pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
    autoPatchelfIgnoreMissingDeps = [ "libmysqlclient.so.21" "libmimerapi.so" "libQt6EglFsKmsGbmSupport.so*" "libQt6VirtualKeyboardQml.so.6" "libQt63DQuickScene3D.so.6" "libQt6VirtualKeyboardQml.so.6" "libspeechd.so.2" ];
    preFixup = ''
      addAutoPatchelfSearchPath ${final.shiboken6}/${final.python.sitePackages}/shiboken6
    '';
    propagatedBuildInputs = old.propagatedBuildInputs or [ ] ++ [
      pkgs.qt6.full
      pkgs.libxkbcommon
      pkgs.gtk3
      pkgs.speechd
      pkgs.gst
      pkgs.gst_all_1.gst-plugins-base
      pkgs.gst_all_1.gstreamer
      pkgs.postgresql.lib
      pkgs.unixODBC
      pkgs.pcsclite
      pkgs.xorg.libxcb
      pkgs.xorg.xcbutil
      pkgs.xorg.xcbutilcursor
      pkgs.xorg.xcbutilerrors
      pkgs.xorg.xcbutilimage
      pkgs.xorg.xcbutilkeysyms
      pkgs.xorg.xcbutilrenderutil
      pkgs.xorg.xcbutilwm
      pkgs.libdrm
      pkgs.pulseaudio
    ];

    # Doesn't do anything
    # pythonImportsCheck = [
    #   "PySide6"
    #   "PySide6.QtCore"
    # ];

    # fails
    # postInstall = ''
    #   python -c 'import PySide6; print(PySide6.__all__)'
    # '';
  });


  # https://pypi.org/project/PyQt6-Qt6/
  # https://github.com/nix-community/poetry2nix/blob/1fb01e90771f762655be7e0e805516cd7fa4d58e/overrides/default.nix#L2871
  pyqt6-qt6 = prev.pyqt6-qt6.overrideAttrs (old: {
    autoPatchelfIgnoreMissingDeps = [ "libmysqlclient.so.21" "libmimerapi.so" "libQt6*" ];
    propagatedBuildInputs = old.propagatedBuildInputs or [ ] ++ [
      pkgs.qt6.full # Isn't this kind of cheating? The whole point of pyqt6-qt6
                    # is to provide only what pyqt6 needs, not the whole qt6.full.
      pkgs.libxkbcommon
      pkgs.gtk3
      pkgs.speechd
      pkgs.gst
      pkgs.gst_all_1.gst-plugins-base
      pkgs.gst_all_1.gstreamer
      pkgs.postgresql.lib
      pkgs.unixODBC
      pkgs.pcsclite
      pkgs.xorg.libxcb
      pkgs.xorg.xcbutil
      pkgs.xorg.xcbutilcursor
      pkgs.xorg.xcbutilerrors
      pkgs.xorg.xcbutilimage
      pkgs.xorg.xcbutilkeysyms
      pkgs.xorg.xcbutilrenderutil
      pkgs.xorg.xcbutilwm
      pkgs.libdrm
      pkgs.pulseaudio
    ];
  });

  pyside6-addons = prev.pyside6-addons.overrideAttrs (_old: pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
    autoPatchelfIgnoreMissingDeps = [
      "libmysqlclient.so.21"
      "libmimerapi.so"
      "libQt63DQuickLogic.so.6"
      "libpcsclite.so.1"
      "libspeechd.so.2"
    ];
    preFixup = ''
          addAutoPatchelfSearchPath ${final.shiboken6}/${final.python.sitePackages}/shiboken6
          addAutoPatchelfSearchPath ${final.pyside6-essentials}/${final.python.sitePackages}/PySide6
          addAutoPatchelfSearchPath $out/${final.python.sitePackages}/PySide6
        '';
    buildInputs = [
      pkgs.nss
      pkgs.xorg.libXtst
      pkgs.alsa-lib
      pkgs.xorg.libxshmfence
      pkgs.xorg.libxkbfile
    ];
    postInstall = ''
          rm -r $out/${final.python.sitePackages}/PySide6/__pycache__/
        '';
  });
  pyside6 = prev.pyside6.overrideAttrs (_old: {
    # The PySide6/__init__.py script tries to find the Qt libraries
    # relative to its own path in the installed site-packages directory.
    # This then fails to find the paths from pyside6-essentials and
    # pyside6-addons because they are installed into different directories.
    #
    # To work around this issue we symlink all of the files resulting from
    # those packages into the aggregated `pyside6` output directories.
    #
    # See https://github.com/nix-community/poetry2nix/issues/1791 for more details.
    postFixup = ''
          ${pkgs.xorg.lndir}/bin/lndir ${final.pyside6-essentials}/${final.python.sitePackages}/PySide6 $out/${final.python.sitePackages}/PySide6
          ${pkgs.xorg.lndir}/bin/lndir ${final.pyside6-addons}/${final.python.sitePackages}/PySide6 $out/${final.python.sitePackages}/PySide6
          rm -r $out/${final.python.sitePackages}/PySide6/__pycache__/
        '';
  });
}
