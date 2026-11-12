function ytop --description 'Stream YouTube audio via MPV'
    # Check if the argument is a direct URL
    if string match -q 'https://*' "$argv[1]"
        mpv --no-video "$argv[1]"
    else
        # If not, treat the whole argument string as a search query
        mpv --no-video "ytdl://ytsearch1:$argv"
    end
end
