function descriptor()
    return {
        title = "Object Detector";
        version = "0.1";
        decription = [[ 
Object Detector.

Object Detector is a VLC extension that allows a user to search for objects in a video file.
        ]];
        capabilities = {"menu"}
    }
end

function activate()
    create_dialog()
end

function deactivate()
end

function close()
    vlc.deactivate()
end

function meta_changed()
end

function create_dialog()
    dlg = vlc.dialog(descriptor().title)
    dlg:add_label("<b>Search for Object:</b>", 1, 1, 1, 1)
    object_name = dlg:add_text_input("", 2, 1, 4, 1)
    dlg:add_label("<b>Search in Subtitles:</b>", 1, 2, 1, 1)
    subtitle_text = dlg:add_text_input("", 2, 2, 4, 1)
    dlg:add_button("Start", click_START, 1, 3, 1, 1)
    dlg:add_button("Stop", click_STOP, 4, 3, 1, 1)
end

function click_START()
end

function click_STOP()
end
