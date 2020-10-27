function PTBwrite_msg(el,msg, coordX, coordY)
    coordX_ = coordX;
    coordY_ = coordY;

    if ~isnumeric(coordX)
        coordX_ = 0;
    end

    if ~isnumeric(coordY)
        coordY_ = 0;
    end

    screenCoord = PTBcenter_to_screen([coordX_, coordY_],el);

    coordX_ = screenCoord(1);
    coordY_ = screenCoord(2);

    if ~isnumeric(coordX)
        coordX_ = coordX;
        coordY_ = screenCoord(2);
    end

    if ~isnumeric(coordY)
        coordX_ = screenCoord(1);
        coordY_ = coordY;
    end

    DrawFormattedText(el.window, msg, coordX_, coordY_, el.msgfontcolour2);
end