local DELAY_AFTER_CLICK = 0.25


function menu(x, y, content)
    local old_backgorund_color = term.getBackgroundColor()
    local old_text_color = term.getTextColor()

    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)

    local all_closed = true
    local menu_width = 0
    for i=1, #content do
        if content[i][1] ~= "-" then
            if menu_width < #content[i][1] then
                menu_width = #content[i][1]
                all_closed = content[i][2] and all_closed or false
            end
        end
    end

    if all_closed then
        return ""
    end

    menu_width = menu_width + 2

    term.setCursorPos(x, y)
    paintutils.drawBox(x + 1, y + 1, x + menu_width, y + #content, colors.gray)
    paintutils.drawFilledBox(x, y, x + menu_width - 1, y + #content - 1, colors.white)

    for i=1, #content do
        if content[i][1] == "-" then
            term.setTextColor(colors.gray)
            term.setCursorPos(x, y + i - 1)
            term.write(string.rep("-", menu_width))
        else
            if content[i][2] then
                term.setTextColor(colors.lightGray)
            else
                term.setTextColor(colors.black)
            end
            term.setCursorPos(x + 1, y + i - 1)
            term.write(content[i][1])
        end
    end

    local selected_option = nil
    
    local _, button, click_x, click_y = os.pullEvent("mouse_click")

    if button == 1 then
        if click_x >= x and click_x <= x + menu_width - 1 and click_y >= y and click_y <= y + #content - 1 then
            local selected = content[click_y - y + 1]

            if selected[1] ~= "-" and not selected[2] then
                selected_option = selected[1]

                term.setBackgroundColor(colors.blue)
                term.setTextColor(colors.white)

                paintutils.drawLine(x, click_y, x + menu_width - 1, click_y, colors.blue)
                term.setCursorPos(x + 1, click_y)

                term.write(selected[1])

                os.sleep(DELAY_AFTER_CLICK)
            end
        end
    end

    term.setBackgroundColor(old_backgorund_color)
    term.setTextColor(old_text_color)

    return selected_option
end


return {
    menu = menu
}
