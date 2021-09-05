local replacers = {
    -- Bold Italics
    {
        "%*%*%*(.-)%*%*%*";
        function(s: string): string
            return string.format("<b><i>%s</i></b>", s)
        end;
    };
    -- Bold
    {
        "%*%*(.-)%*%*";
        function(s: string): string
            return string.format("<b>%s</b>", s)
        end;
    };
    -- Italics
    {
        "%*(.-)%*";
        function(s: string): string
            return string.format("<i>%s</i>", s)
        end;
    };
    -- Underline
    {
        "__(.-)__";
        function(s: string): string
            return string.format("<u>%s</u>", s)
        end;
    };
    -- Strikethrough
    {
        "~~(.-)~~";
        function(s: string): string
            return string.format("<s>%s</s>", s)
        end;
    };
}

return function(text: string): string
    for _, v in pairs(replacers) do
        text = string.gsub(text, v[1], v[2])
    end
    return text
end