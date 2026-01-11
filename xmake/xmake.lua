-- define rule: qt quickapp
rule("my.qt.quickapp")
    add_deps("qt.qrc", "qt.moc", "qt._wasm_app", "qt.ts")

    -- we must set kind before target.on_load(), may we will use target in on_load()
    on_load(function (target)
        target:set("kind", target:is_plat("android") and "shared" or "binary")
    end)

    on_config(function (target)
        import("load")(target, {gui = true, frameworks = {"QtQuickControls2", "QtQuickEffects", "QtSql", "QtGui", "QtQuick", "QtQml", "QtCore", "QtNetwork", "QtDBus"}})
    end)

    -- deploy application
    after_build("android", "deploy.android")
    after_build("macosx", "deploy.macosx")

    -- install application for android
    on_install("android", "install.android")
    after_install("windows", "install.windows")
    after_install("mingw", "install.mingw")

    -- install application for xpack
    on_installcmd("installcmd")
    on_uninstallcmd("uninstallcmd")
