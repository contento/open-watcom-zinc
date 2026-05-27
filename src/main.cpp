// Open Zinc demo app - DOS/4GW 386 extended target
// Build with: wmake (Open Watcom 2.0)

#include <ui_win.hpp>
#include <stdio.h>
#include <string.h>

class DemoWindow;
class AboutDialog;

// ---------------------------------------------------------------------------
// Modal "About" dialog
// ---------------------------------------------------------------------------
class AboutDialog : public UIW_WINDOW {
public:
    AboutDialog() : UIW_WINDOW(15, 6, 50, 10, WOF_BORDER, WOAF_MODAL)
    {
        *this
            + new UIW_TITLE("About")
            + new UIW_PROMPT(2, 1, 44, "Open Watcom + Open Zinc Demo")
            + new UIW_PROMPT(2, 2, 44, "Target : DOS 6.x / DOS/4GW 32-bit")
            + new UIW_PROMPT(2, 3, 44, "CPU    : 80386+ (DOSBox-X)")
            + new UIW_PROMPT(2, 4, 44, "UI     : Open Zinc (text mode)")
            + new UIW_BUTTON(19, 7, 8, "OK",
                             BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                             ZIL_NULLF(ZIL_USER_FUNCTION), L_EXIT);
    }
};

// ---------------------------------------------------------------------------
// Main application window
// ---------------------------------------------------------------------------
class DemoWindow : public UIW_WINDOW {
    UIW_STRING  *inputField;
    UIW_TEXT    *outputLabel;
    int          clickCount;

public:
    enum {
        ID_BTN_CLICK  = 100,
        ID_BTN_ECHO,
        ID_BTN_EXIT,
        ID_MENU_EXIT,
        ID_MENU_ABOUT,
    };

    DemoWindow() : UIW_WINDOW(2, 1, 76, 22, WOF_BORDER), clickCount(0)
    {
        *this + new UIW_TITLE("Open Watcom + Open Zinc  -  DOS/4GW 386 Demo");

        *this + new UIW_PROMPT(2, 2, 70,
                               "Welcome! This app runs on DOS 6.x with 80386 extended memory.");

        outputLabel = new UIW_TEXT(2, 4, 70, 1,
                                   "Click a button or type in the input field.",
                                   -1, WNF_NO_WRAP, WOF_NO_FLAGS);
        *this + outputLabel;

        *this + new UIW_PROMPT(2, 7, 8, "Input:");
        inputField = new UIW_STRING(11, 7, 44, "", 79, STF_NO_FLAGS, WOF_NO_FLAGS);
        *this + inputField;

        *this
            + new UIW_BUTTON(4,  10, 18, "Click Me!",
                             BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                             ZIL_NULLF(ZIL_USER_FUNCTION), ID_BTN_CLICK)
            + new UIW_BUTTON(26, 10, 18, "Echo Input",
                             BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                             ZIL_NULLF(ZIL_USER_FUNCTION), ID_BTN_ECHO)
            + new UIW_BUTTON(52, 10, 18, "Exit",
                             BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                             ZIL_NULLF(ZIL_USER_FUNCTION), ID_BTN_EXIT);

        UIW_PULL_DOWN_ITEM *fileMenu = new UIW_PULL_DOWN_ITEM("&File");
        *fileMenu
            + new UIW_POP_UP_ITEM("E&xit", MNIF_NO_FLAGS, BTF_NO_FLAGS,
                                  WOF_NO_FLAGS,
                                  ZIL_NULLF(ZIL_USER_FUNCTION), ID_MENU_EXIT);

        UIW_PULL_DOWN_ITEM *helpMenu = new UIW_PULL_DOWN_ITEM("&Help");
        *helpMenu
            + new UIW_POP_UP_ITEM("&About", MNIF_NO_FLAGS, BTF_NO_FLAGS,
                                  WOF_NO_FLAGS,
                                  ZIL_NULLF(ZIL_USER_FUNCTION), ID_MENU_ABOUT);

        *this + fileMenu + helpMenu;
    }

    virtual EVENT_TYPE Event(const UI_EVENT &event)
    {
        switch (event.type) {
        case ID_BTN_CLICK: {
            char buf[64];
            ++clickCount;
            sprintf(buf, "Button clicked %d time%s!", clickCount,
                    clickCount == 1 ? "" : "s");
            outputLabel->DataSet(buf);
            outputLabel->Event(UI_EVENT(S_REDISPLAY));
            return (EVENT_TYPE)ID_BTN_CLICK;
        }

        case ID_BTN_ECHO: {
            ZIL_ICHAR *text = inputField->DataGet();
            char out[96];
            if (text && text[0] != '\0')
                sprintf(out, "You typed: %s", text);
            else
                strcpy(out, "(input field is empty)");
            outputLabel->DataSet(out);
            outputLabel->Event(UI_EVENT(S_REDISPLAY));
            return (EVENT_TYPE)ID_BTN_ECHO;
        }

        case ID_BTN_EXIT:
        case ID_MENU_EXIT:
            return UIW_WINDOW::Event(UI_EVENT(L_EXIT));

        case ID_MENU_ABOUT:
            if (UI_WINDOW_OBJECT::windowManager)
                UI_WINDOW_OBJECT::windowManager->Add(new AboutDialog);
            return (EVENT_TYPE)ID_MENU_ABOUT;

        default:
            return UIW_WINDOW::Event(event);
        }
    }
};

// ---------------------------------------------------------------------------
// Application entry point (called from z_app.obj's main())
// ---------------------------------------------------------------------------
int UI_APPLICATION::Main(void)
{
    windowManager->Add(new DemoWindow);
    return (int)Control();
}
