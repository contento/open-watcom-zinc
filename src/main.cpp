// Open Zinc demo app — DOS/4GW 386 extended target
// Build with: wmake (Open Watcom 2.0)

#include <ui_win.hpp>

// ---------------------------------------------------------------------------
// Forward declarations
// ---------------------------------------------------------------------------
class DemoWindow;
class AboutDialog;

// ---------------------------------------------------------------------------
// Modal "About" dialog
// ---------------------------------------------------------------------------
class AboutDialog : public UIW_WINDOW {
public:
    AboutDialog() : UIW_WINDOW(15, 6, 50, 10, WOF_BORDER | WOF_SUPPORT_OBJECT,
                               WOAF_MODAL)
    {
        *this
            + new UIW_TEXT(2, 1, 44, 1,
                           "  Open Watcom + Open Zinc Demo",
                           TXF_NO_FLAGS, WOF_NO_FLAGS)
            + new UIW_TEXT(2, 2, 44, 1,
                           "  Target : DOS 6.x / DOS/4GW 32-bit",
                           TXF_NO_FLAGS, WOF_NO_FLAGS)
            + new UIW_TEXT(2, 3, 44, 1,
                           "  CPU    : 80386+ (DOSBox-X)",
                           TXF_NO_FLAGS, WOF_NO_FLAGS)
            + new UIW_TEXT(2, 4, 44, 1,
                           "  UI     : Open Zinc (text mode)",
                           TXF_NO_FLAGS, WOF_NO_FLAGS)
            + new UIW_PUSH_BUTTON(19, 7, 12, "OK",
                                  BTF_NO_FLAGS, WOF_NO_FLAGS,
                                  ZIL_NULLP(void), L_EXIT);
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
        ID_BTN_CLICK = 100,
        ID_BTN_ECHO,
        ID_BTN_EXIT,
        ID_MENU_EXIT,
        ID_MENU_ABOUT,
    };

    DemoWindow() : UIW_WINDOW(2, 1, 76, 22, WOF_BORDER | WOF_SUPPORT_OBJECT),
                   clickCount(0)
    {
        SetTitle("  Open Watcom + Open Zinc --- DOS/4GW 386 Demo  ");

        // Static description text
        *this + new UIW_TEXT(2, 2, 70, 1,
                             "Welcome! This app runs on DOS 6.x with 80386 extended memory.",
                             TXF_NO_FLAGS, WOF_NO_FLAGS);

        // Output label — updated by button events
        outputLabel = new UIW_TEXT(2, 4, 70, 1,
                                   "Click the button below or type in the input field.",
                                   TXF_NO_FLAGS, WOF_NO_FLAGS);
        *this + outputLabel;

        // Input field
        *this + new UIW_TEXT(2, 7, 12, 1, "Input:", TXF_NO_FLAGS, WOF_NO_FLAGS);
        inputField = new UIW_STRING(15, 7, 40, "", 79, STF_NO_FLAGS, WOF_NO_FLAGS);
        *this + inputField;

        // Buttons
        *this
            + new UIW_PUSH_BUTTON(4,  10, 18, "Click Me!",
                                  BTF_NO_FLAGS, WOF_NO_FLAGS,
                                  ZIL_NULLP(void), ID_BTN_CLICK)
            + new UIW_PUSH_BUTTON(26, 10, 18, "Echo Input",
                                  BTF_NO_FLAGS, WOF_NO_FLAGS,
                                  ZIL_NULLP(void), ID_BTN_ECHO)
            + new UIW_PUSH_BUTTON(52, 10, 18, "Exit",
                                  BTF_NO_FLAGS, WOF_NO_FLAGS,
                                  ZIL_NULLP(void), ID_BTN_EXIT);

        // Menu bar
        UIW_MENU *menu = new UIW_MENU(0, 0, WNF_NO_FLAGS);

        UIW_POP_UP_ITEM *fileMenu = new UIW_POP_UP_ITEM("&File", MNIF_NO_FLAGS,
                                                         BTF_NO_FLAGS, WOF_NO_FLAGS);
        *fileMenu + new UIW_POP_UP_ITEM("E&xit", MNIF_NO_FLAGS,
                                         BTF_NO_FLAGS, WOF_NO_FLAGS,
                                         ZIL_NULLP(void), ID_MENU_EXIT);

        UIW_POP_UP_ITEM *helpMenu = new UIW_POP_UP_ITEM("&Help", MNIF_NO_FLAGS,
                                                         BTF_NO_FLAGS, WOF_NO_FLAGS);
        *helpMenu + new UIW_POP_UP_ITEM("&About", MNIF_NO_FLAGS,
                                         BTF_NO_FLAGS, WOF_NO_FLAGS,
                                         ZIL_NULLP(void), ID_MENU_ABOUT);

        *menu + fileMenu + helpMenu;
        *this + menu;
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
            return ID_BTN_CLICK;
        }

        case ID_BTN_ECHO: {
            char buf[80];
            inputField->DataGet(buf, sizeof(buf));
            char out[96];
            if (buf[0] != '\0')
                sprintf(out, "You typed: %s", buf);
            else
                strcpy(out, "(input field is empty)");
            outputLabel->DataSet(out);
            outputLabel->Event(UI_EVENT(S_REDISPLAY));
            return ID_BTN_ECHO;
        }

        case ID_BTN_EXIT:
        case ID_MENU_EXIT:
            return UIW_WINDOW::Event(UI_EVENT(L_EXIT));

        case ID_MENU_ABOUT: {
            UI_WINDOW_MANAGER *windowManager =
                ZIL_APPLICATION::defaultStorage->objectManager;
            if (windowManager)
                windowManager->Add(new AboutDialog);
            return ID_MENU_ABOUT;
        }

        default:
            return UIW_WINDOW::Event(event);
        }
    }
};

// ---------------------------------------------------------------------------
// Application entry point
// ---------------------------------------------------------------------------
int main(void)
{
    ZIL_APPLICATION *application = new ZIL_APPLICATION;

    DemoWindow *win = new DemoWindow;
    application->Add(win);

    application->Control();   // run the Zinc event loop

    delete application;
    return 0;
}
