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
    USER = "karl"
    local_directory = "/home/" .. USER .. "/.local/share/vlc/lua/extensions/"
    vlc.msg.info("Object Detector activating")
    create_dialog()
end

function deactivate()
    vlc.deactivate()
end

function close()
    os.execute("rm " .. local_directory .. "object_detection_output.txt")
    os.execute("rm " .. local_directory .. "frame*.jpg")
    vlc.deactivate()
    vlc.msg.info("Object Detector closed")
end

function meta_changed()
end

function create_dialog()
    dlg = vlc.dialog(descriptor().title)
    dlg:add_label("<b>Search for Object:</b>", 1, 1, 1, 1)
    object_name = dlg:add_text_input("", 1, 2, 3, 1)
    --dlg:add_label("<b>Search in Subtitles:</b>", 1, 2, 1, 1)
    --subtitle_text = dlg:add_text_input("", 2, 2, 4, 1)
    dlg:add_label("<b>Start Time:</b>",1, 3, 1, 1)
    start_time_hours_text = dlg:add_text_input("0", 1, 4, 1, 1)
    dlg:add_label("<b>h</b>", 2, 4, 1, 1)
    start_time_minutes_text = dlg:add_text_input("0", 3, 4, 1, 1)
    dlg:add_label("<b>m</b>", 4, 4, 1, 1)
    start_time_seconds_text = dlg:add_text_input("0", 5, 4, 1, 1)
    dlg:add_label("<b>s</b>", 6, 4, 1, 1)
    dlg:add_button("Search", click_SEARCH, 1, 5, 1, 1)
    dlg:add_button("Stop", click_STOP, 3, 5, 1, 1)
    dlg:add_button("Reset", click_RESET, 5, 5, 1, 1)
    result_label = dlg:add_label("<b> </b>", 1, 6, 1, 1)
    dlg:add_image(local_directory .. "logo.png", 1, 7, 3, 3)

    vlc.msg.info("Object Detector dialog created")
end

function click_SEARCH()

    if not vlc.input.is_playing() then
        result_label:set_text("<b></b>")
        dlg:add_image(local_directory .. "logo.png", 1, 7, 3, 3)
        return
    end

    result_label:set_text("<b>Searching ...</b>")
    
    local f = io.open(local_directory .. "object_detection_output.txt", "r")
    if f ~= nil then
        io.close(f)
        os.remove(local_directory .. "object_detection_output.txt")
    end
    
    local item = vlc.input.item()
    local video_file_directory = item:uri()
    video_file_directory = string.gsub(video_file_directory, '^file://', '')
    video_file_directory = string.gsub(video_file_directory, '%%20', '\\ ')
    object_detection_script_directory = local_directory .. "video_object_detection.py"
    
    local time = tostring(tonumber(start_time_hours_text:get_text())*3600 + tonumber(start_time_minutes_text:get_text())*60 + tonumber(start_time_seconds_text:get_text()))

    vlc.msg.info("Object Detector Starting Search for " .. object_name:get_text() .. " in " .. video_file_directory)
    cmd = "python3 " .. object_detection_script_directory .. " " .. video_file_directory .. " " .. object_name:get_text() .. " " .. time .. " 0"
    vlc.msg.info("Running command: " .. cmd)
   
    os.execute(cmd)
    
    local f = io.open(local_directory .. "object_detection_output.txt", "r")
    if f ~= nil then  
        result_frame = f:read "*line"
        result_time = f:read "*line"
        result_label:set_text("<b>Object Found at time " .. result_time .. "</b>")
        dlg:add_image(local_directory .. "frame".. result_frame .. ".jpg", 1,7,3,3)
        gotoframe_button = dlg:add_button("Go To Frame", click_JUMP, 3, 6, 1, 1)
        io.close(f)
        --os.remove(local_directory .. "object_detection_output.txt")
    else
        result_label:set_text("<b>No Result</b>")
    end
end

function click_STOP()
    vlc.msg.info("Object Detector Stopping the Search")
    if result_label:get_text() == "<b>Searching ...</b>" then
        dlg:add_image(local_directory .. "logo.png", 1,7,3,3)
        result_label:set_text("<b></b>")
        dlg:del_widget(gotoframe_button)
    end
end

function click_RESET()
    vlc.msg.info("Object Detector Resetting GUI")
    dlg:add_image(local_directory .. "logo.png", 1,7,3,3)
    result_label:set_text("<b></b>")
    dlg:del_widget(gotoframe_button)
end


function click_JUMP()
    local time_in_s = timestring_to_seconds(result_time)
	vlc.msg.info("Object Detector jumping to time " .. result_time .. " or " .. tostring(time_in_s) .. " in seconds.")
    local input_vid=vlc.object.input()
    if input_vid then vlc.var.set(input_vid, "time", time_in_s*1000000) end
end

function timestring_to_seconds(timestring) 
    timestring = SplitString(timestring, ":")

    return tonumber(timestring[1])*3600 + tonumber(timestring[2])*60 + tonumber(timestring[3])
end

function SplitString(s, d) -- string, delimiter pattern
    local t={}
    local i=1
    local ss, j, k
    local b=false
    while true do
        j,k = string.find(s,d,i)
        if j then
            ss=string.sub(s,i,j-1)
            i=k+1
        else
            ss=string.sub(s,i)
            b=true
        end
        table.insert(t, ss)
        if b then break end
    end
    return t
end

