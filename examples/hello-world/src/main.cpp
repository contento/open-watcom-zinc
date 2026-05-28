// Hello World - minimal Open Zinc + Watcom tutorial
// Build with: wmake (Open Watcom 2.0)

#include <ui_win.hpp>

class HelloWindow : public UIW_WINDOW {
public:
    enum { ID_BTN_EXIT = 100 };

    HelloWindow() : UIW_WINDOW(10, 5, 60, 10, WOF_BORDER)
    {
        *this
            + new UIW_TITLE("Hello, World!")
            + new UIW_PROMPT(2, 2, 54, "Welcome to Open Zinc!")
            + new UIW_PROMPT(2, 4, 54, "This is a minimal tutorial application.")
            + new UIW_BUTTON(22, 6, 16, "Exit",
                             BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                             ZIL_NULLF(ZIL_USER_FUNCTION), ID_BTN_EXIT);
    }

    virtual EVENT_TYPE Event(const UI_EVENT &event)
    {
        switch (event.type) {
        case ID_BTN_EXIT:
            if (UI_WINDOW_OBJECT::eventManager)
                UI_WINDOW_OBJECT::eventManager->Put(UI_EVENT(L_EXIT));
            return (EVENT_TYPE)L_EXIT;

        default:
            return UIW_WINDOW::Event(event);
        }
    }
};

int UI_APPLICATION::Main(void)
{
    windowManager->Add(new HelloWindow);
    return (int)Control();
}
