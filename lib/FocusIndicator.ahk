class FocusIndicator {
    __New(opts := Map()) {
        this.gui := Gui(
            " +AlwaysOnTop"
            " +ToolWindow"
            " +E" WS_EX_NOACTIVATE
            " -Caption"
            " -SysMenu"
        )

        o := Map()
        for k, v in opts.OwnProps() {
            o[k] := v
        }

        this.Color      := o.Get("color", "0xf79802")
        this._thickness := o.Get("thickness", 1)

        this.gui.Show("Hide")
    }

    __Delete() {
        this.gui.Destroy()
    }

    Color {
        get => this.gui.BackColor
        set => this.gui.BackColor := value
    }

    _show(hwnd) {
        WinGetPos(&left, &top, &width, &height, "ahk_id" hwnd)
        bounds := ExtendedFrameBounds(hwnd)

        x := left + bounds.left
        y := top + bounds.top
        width := width - bounds.left - bounds.right
        height := height - bounds.top - bounds.bottom

        if width < 0 || height < 0 {
            return
        }

        xa := this._thickness
        ya := this._thickness
        xb := width - xa
        yb := height - ya

        WinSetRegion(
            Format(
                "0-0 {}-0 {}-{} 0-{} 0-0 "
                "{}-{} {}-{} {}-{} {}-{} {}-{} ",
                width, width, height, height,
                xa, ya, xb, ya, xb, yb, xa, yb, xa, ya,
            ),
            "ahk_id" this.gui.Hwnd,
        )

        DllCall(
            "SetWindowPos",
            "Ptr", this.gui.Hwnd,
            "Int", hwnd,
            "Int", x,
            "Int", y,
            "Int", width,
            "Int", height,
            "UInt", SWP_SHOWWINDOW | SWP_NOACTIVATE,
            "Int",
        )

        DllCall(
            "SetWindowPos",
            "Ptr", hwnd,
            "Int", this.gui.Hwnd,
            "Int", 0,
            "Int", 0,
            "Int", 0,
            "Int", 0,
            "UInt", SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOCOPYBITS | SWP_NOSENDCHANGING,
            "Int",
        )
    }

    Show(hwnd) {
        RunDpiAware(() => this._show(hwnd))
    }

    Hide() {
        this.gui.Show("Hide")
    }
}
