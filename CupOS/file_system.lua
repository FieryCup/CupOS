function move_to_previous_folder(files_windows, current_folder, page_index, files_per_page)
    if current_folder ~= "." then
        local current_folder_table = {}

        for i in string.gmatch(current_folder, "([^/]+)") do
        table.insert(current_folder_table, i)
        end

        current_folder = {}
        for i=0, #current_folder_table - 1 do
            table.insert(current_folder, current_folder_table[i])
        end

        current_folder = table.concat(current_folder, "/")
        page_index = 0
    end
    return current_folder, page_index
end

function open_folder(current_folder, file)
    return current_folder .. "/" .. file
end

function open_folder_icon(current_folder, file)
    return current_folder .. "/" .. file .. "/" .. "icon.cosif"
end

function open_main_file_of_folder(current_folder, file)
    return current_folder .. "/" .. file .. "/" .. "main.lua"
end

return {
    move_to_previous_folder = move_to_previous_folder,
    open_folder = open_folder,
    open_folder_icon = open_folder_icon,
    open_main_file_of_folder = open_main_file_of_folder
}
