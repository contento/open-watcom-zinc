// Phone Keypad - classic phone keyboard interface
// Build with: wmake (Open Watcom 2.0)

#include <ui_win.hpp>

class PhoneKeypad : public UIW_WINDOW {
public:
    enum {
        ID_BTN_1 = 101, ID_BTN_2, ID_BTN_3,
        ID_BTN_4, ID_BTN_5, ID_BTN_6,
        ID_BTN_7, ID_BTN_8, ID_BTN_9,
        ID_BTN_STAR, ID_BTN_0, ID_BTN_HASH,
        ID_BTN_CLEAR
    };

    UIW_TEXT *display;

    PhoneKeypad() : UIW_WINDOW(8, 3, 35, 18, WOF_BORDER)
    {
        *this + new UIW_TITLE("Phone Keypad");

        display = new UIW_TEXT(2, 2, 25, 1, "Press a button", -1, WNF_NO_WRAP, WOF_NO_FLAGS);
        *this + display;

        char *labels[] = {
            (char *)"1", (char *)"2", (char *)"3",
            (char *)"4", (char *)"5", (char *)"6",
            (char *)"7", (char *)"8", (char *)"9",
            (char *)"*", (char *)"0", (char *)"#"
        };
        int ids[] = {
            ID_BTN_1, ID_BTN_2, ID_BTN_3,
            ID_BTN_4, ID_BTN_5, ID_BTN_6,
            ID_BTN_7, ID_BTN_8, ID_BTN_9,
            ID_BTN_STAR, ID_BTN_0, ID_BTN_HASH
        };

        for (int i = 0; i < 12; ++i) {
            int col = i % 3;
            int row = i / 3;
            int x = 2 + col * 8;
            int y = 5 + row * 3;

            *this + new UIW_BUTTON(x, y, 6, labels[i],
                                   BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                                   ZIL_NULLF(ZIL_USER_FUNCTION), ids[i]);
        }

        *this + new UIW_BUTTON(8, 15, 18, (char *)"Clear", BTF_NO_FLAGS, WOF_JUSTIFY_CENTER,
                               ZIL_NULLF(ZIL_USER_FUNCTION), ID_BTN_CLEAR);
    }

    virtual EVENT_TYPE Event(const UI_EVENT &event)
    {
        char *labels[] = {
            (char *)"1", (char *)"2", (char *)"3",
            (char *)"4", (char *)"5", (char *)"6",
            (char *)"7", (char *)"8", (char *)"9",
            (char *)"*", (char *)"0", (char *)"#"
        };
        int ids[] = {
            ID_BTN_1, ID_BTN_2, ID_BTN_3,
            ID_BTN_4, ID_BTN_5, ID_BTN_6,
            ID_BTN_7, ID_BTN_8, ID_BTN_9,
            ID_BTN_STAR, ID_BTN_0, ID_BTN_HASH
        };

        for (int i = 0; i < 12; ++i) {
            if (event.type == ids[i]) {
                char buf[32];
                sprintf(buf, "Pressed: %s", labels[i]);
                display->DataSet(buf);
                display->Event(UI_EVENT(S_REDISPLAY));
                return (EVENT_TYPE)ids[i];
            }
        }

        if (event.type == ID_BTN_CLEAR) {
            display->DataSet("Press a button");
            display->Event(UI_EVENT(S_REDISPLAY));
            return (EVENT_TYPE)ID_BTN_CLEAR;
        }

        return UIW_WINDOW::Event(event);
    }
};

int UI_APPLICATION::Main(void)
{
    windowManager->Add(new PhoneKeypad);
    return (int)Control();
}
