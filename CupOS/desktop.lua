local painter = require("CupOS.api.gui.image")
local file_system = require("CupOS.file_system")
local context = require("CupOS.api.context")
local errors = require("CupOS.api.errors")
local expect = require("cc.expect")

local width, height = term.getSize()

local DESKTOP_BACKGROUND_COLOR = colors.black
local DIR_NAME_LENGTH = width - 6
local FS_POS_X = 2
local FS_POS_Y = 3
local DELAY_AFTER_CLICK = 0.25
local HOME_BUTTON_POS = {x = 1, y = 1}
local GO_TO_PARENT_DIRECTORY_BUTTON_POS = {x = 2, y = 1}

local fs_window_width = math.floor((width - 2) / 12)
local fs_window_height = math.floor((height - 4) / 7)


local function create_files_windows()
    local fs_window = window.create(term.current(), FS_POS_X, FS_POS_Y, fs_window_width * 12, 14)
    local fs_width, fs_height = fs_window.getSize()
    
    local files_windows = {}
    for y=1, fs_window_height do
        for x=1, fs_window_width do
            file_window = window.create(fs_window, 
            math.floor(fs_width / fs_window_width * (x - 1) + 1), math.floor(fs_height / fs_window_height * (y - 1) + 1), 12, 7)
            file_window.clear()
            table.insert(files_windows, file_window)
        end
    end
    return files_windows
end


local function draw_files(files_windows, current_folder, page_index, files_per_page, cur_x, cur_y, redraw_all)
    local files = fs.list(current_folder)

    if redraw_all then
        term.setTextColor(colors.white)
        term.setBackgroundColor(DESKTOP_BACKGROUND_COLOR)
        term.clear()

        term.setBackgroundColor(colors.gray)
        term.setCursorPos(4, 1)
        term.clearLine()
    
        if #current_folder <= DIR_NAME_LENGTH then
            term.write(current_folder)
        else
            term.write("..." .. string.sub(current_folder, #current_folder - DIR_NAME_LENGTH + 4, #current_folder))
        end
    
        term.setCursorPos(HOME_BUTTON_POS.x, HOME_BUTTON_POS.y)
        term.blit("\21", "0", "8")
        term.setCursorPos(GO_TO_PARENT_DIRECTORY_BUTTON_POS.x, GO_TO_PARENT_DIRECTORY_BUTTON_POS.y)
        term.blit("\27", "0", "8")
        term.setBackgroundColor(DESKTOP_BACKGROUND_COLOR)
    
        term.setCursorPos(2, height - 1)
        term.write(page_index+1 .. "/" .. math.floor(#fs.list(current_folder) / files_per_page - 0.01) + 1)
    end

    for file_number, file_icon in pairs(files_windows) do
        local file_width, file_height = file_icon.getSize()
        local file_name = files[file_number + (page_index * files_per_page)]

        file_icon.setBackgroundColor(DESKTOP_BACKGROUND_COLOR)
        file_icon.clear()

        if file_name ~= nil then

            if file_number == cur_x + (cur_y - 1) * fs_window_width then
                file_icon.setBackgroundColor(colors.blue)
                file_icon.clear()
            end

            local formated_file_name

            if #file_name <= file_width - 2 then
                formated_file_name = file_name
            else
                formated_file_name = string.sub(file_name, 1, file_width - 5) .. "..."
            end

            file_icon.setCursorPos((file_width - #formated_file_name) / 2 + 1, file_height - 1)
            file_icon.write(formated_file_name)

            local folder_icon = painter.load("CupOS/images/icons/folder.cosif")
            local unknown_file_icon = painter.load("CupOS/images/icons/unknown_file.cosif")

            if fs.isDir(file_system.open_folder(current_folder, file_name)) then
                icon_file = file_system.open_folder_icon(current_folder, file_name)
                if fs.exists(icon_file) then
                    painter.draw(painter.load(icon_file), 4, 1, file_icon)
                else
                    painter.draw(folder_icon, 4, 1, file_icon)
                end
            else
                local file_type_table = {}

                for i in string.gmatch(file_name, "([^.]+)") do
                    table.insert(file_type_table, i)
                end

                local file_type = file_type_table[#file_type_table]

                local file_icons = {
                    lua = true,
                    cosif = true
                }

                if file_icons[file_type] then
                    painter.draw(
                        painter.load("CupOS/images/icons/" .. file_type .. "_file.cosif"), 4, 1, file_icon)
                else
                    painter.draw(unknown_file_icon, 4, 1, file_icon)
                end
            end
        end
    end
end

local function run_programm(path)

    expect.expect(1, path, "string")

    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()
    local func, err = load(data)
    if not func then
        errors.bsod(path, "A compilation error has occurred", err)
    else
        --#func is a function
        local status, err = pcall(func)
        if not status then
            errors.bsod(path, "A runtime error has occurred", err)
        end
    end
end


function run()
    term.setCursorPos(1, 1)
    term.setCursorBlink(false)
    term.setBackgroundColor(DESKTOP_BACKGROUND_COLOR)
    term.setTextColor(colors.white)
    term.clear()

    local current_folder = "."
    local previous_current_folder = current_folder

    local page_index = 0
    local previous_page_index = page_index
    local files_per_page = fs_window_width * fs_window_height
    local max_page_index = math.floor(#fs.list(current_folder) / files_per_page - 0.01)

    local files_windows = create_files_windows()

    draw_files(files_windows, current_folder, page_index, files_per_page, 0, 0, true)

    while (true) do
        files_per_page = fs_window_width * fs_window_height
        max_page_index = math.floor(#fs.list(current_folder) / files_per_page - 0.01)
        
        if previous_page_index ~= page_index or previous_current_folder ~= current_folder then
            previous_current_folder = current_folder
            previous_page_index = page_index

            draw_files(files_windows, current_folder, page_index, files_per_page, 0, 0, true)
        end

        local event, a, b, c = os.pullEvent()

        if event == "mouse_scroll" then
            local dir = a

            previous_page_index = page_index
            page_index = dir > 0 and page_index + 1 or page_index - 1
            page_index = page_index > max_page_index and max_page_index or page_index
            page_index = page_index < 0 and 0 or page_index
        end
        if event == "mouse_click" then
            local button, x, y = a, b, c

            local cur_x = 0
            local cur_y = 0
            
            if x >= FS_POS_X and x <= FS_POS_X + 12 * fs_window_width then
                cur_x = math.floor((x - FS_POS_X) / 12) + 1
            end

            if y >= FS_POS_Y and y <= FS_POS_Y + 6 * fs_window_height then
                cur_y = math.floor((y - FS_POS_Y) / 6) + 1
            end

            if button == 1 then
                
                if cur_x ~= 0 and cur_y ~= 0 then
                    local file_number = page_index * files_per_page + (cur_y - 1) * fs_window_width + (cur_x - 1)
                
                    local files = fs.list(current_folder)
                    local file = files[file_number+1]

                    if file ~= nil then
                        draw_files(files_windows, current_folder, page_index, files_per_page, cur_x, cur_y, false)
                        os.sleep(DELAY_AFTER_CLICK)

                        if fs.isDir(file_system.open_folder(current_folder, file)) then

                            main_file = file_system.open_main_file_of_folder(current_folder, file)

                            if fs.exists(main_file) then
                                term.setBackgroundColor(colors.black)
                                term.setTextColor(colors.white)
                                term.setCursorPos(1, 1)
                                term.clear()
                                
                                run_programm(main_file)
                            else
                                previous_current_folder = current_folder
                                current_folder = file_system.open_folder(current_folder, file)
                                page_index = 0
                            end
                        else
                            local file_name = file_system.open_folder(current_folder, file)
                            file_name = file_name:sub(2, #file_name)

                            term.setBackgroundColor(colors.black)
                            term.setTextColor(colors.white)
                            term.setCursorPos(1, 1)
                            term.clear()
                            
                            run_programm(file_name)
                        end

                        draw_files(files_windows, current_folder, page_index, files_per_page, 0, 0, true)
                    end
                end
                if x == HOME_BUTTON_POS.x and y == HOME_BUTTON_POS.y then
                    previous_current_folder = current_folder
                    current_folder = "."
                    page_index= 0
                elseif x == GO_TO_PARENT_DIRECTORY_BUTTON_POS.x and y == GO_TO_PARENT_DIRECTORY_BUTTON_POS.y then
                    previous_current_folder = current_folder
                    current_folder, page_index = file_system.move_to_previous_folder(files_windows, current_folder, page_index, files_per_page)
                end
            elseif button == 2 then
                if cur_x ~= 0 and cur_y ~= 0 then
                    local file_number = page_index * files_per_page + (cur_y - 1) * fs_window_width + (cur_x - 1)
                
                    local files = fs.list(current_folder)
                    local file = files[file_number+1]

                    if file ~= nil then
                        local file_directory = file_system.open_folder(current_folder, file)
        
                        local content = {
                            {"edit"},
                            {"open"},
                            {"-"},
                            {"copy", true},
                            {"paste", true},
                            {"rename", true},
                            {"delete"},
                            {"restart OS"}
                        }
        
                        local selected_option = context.menu(x, y, content)
        
                        if selected_option == "delete" then
                            if fs.isReadOnly(file_directory) then
                                errors.bsod(nil, "The file is read-only")
                            else
                                fs.delete(file_directory)
                            end
                        end

                        if selected_option == "restart OS" then
                            os.reboot()
                        end
                        
                        draw_files(files_windows, current_folder, page_index, files_per_page, 0, 0, true)
                    end
                end
            end
        end
        if event == "key_up" then
            key = a

            if keys.getName(key) == "backspace" then
                previous_current_folder = current_folder
                current_folder, page_index = file_system.move_to_previous_folder(files_windows, current_folder, page_index, files_per_page)
            end
        end
    end
end

return {
    run = run
}
