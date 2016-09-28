Redmine::Plugin.register :redmine_embed_html5_video do
  name 'Embed Html5 Video plugin'
  author 'Richard Gertis'
  description 'Embeds attachment videos, video URLs or Youtube videos. Usage (as macro): video(ID|URL|YOUTUBE_URL). Updated to HTML5'
  version '0.0.1'
  #url 'http://example.com/path/to/plugin'
  #author_url 'http://example.com/about'
end

Redmine::WikiFormatting::Macros.register do
    desc "Wiki embed html5 video:\n\n" +
	"{{video(file [, width] [, height])}}"
    macro :video do |obj, args|
        @width = args[1].gsub(/\D/,'') if args[1]
        @height = args[2].gsub(/\D/,'') if args[2]
        @width ||= 400
        @height ||= 300
        @num ||= 0
        @num = @num + 1

        attachment = obj.attachments.find_by_filename(args[0]) if obj.respond_to?('attachments')
	
	if attachment
            file_url = url_for(:only_path => false, :controller => 'attachments', :action => 'download', :id => attachment, :filename => attachment.filename)
        else
            file_url = args[0].gsub(/<.*?>/, '').gsub(/&lt;.*&gt;/,'')
        end
 	
	case file_url
	# check if youtube-URL, extract youtubeID and assign to local variable {youtubeID}
	when /^https?:\/\/((www\.)?youtube\.com\/(watch\?([\w\d\=]*\&)*v=|embed\/){1}|youtu\.be\/)(?<youtubeID>[\w\d\-]*)((\&|\/)[\w\d\=\-]*)*$/
		video_url = "https://www.youtube.com/embed/#{$LAST_MATCH_INFO['youtubeID']}"
		embed_typ = "iframe"
        when /^https?:\/\/(www\.)?vimeo\.com\/(?<vimeoID>[\d]*)((\D)[\w\d\=\-]*)*$/
                video_url = "https://player.vimeo.com/video/#{$LAST_MATCH_INFO['vimeoID']}"
                embed_typ = "iframe"
	else
		# Currently, there are 3 supported video formats for the <video> element: MP4, WebM, and Ogg
		# http://www.w3schools.com/tags/tag_video.asp
		video_url = file_url
		embed_typ = "video"
	end

	case embed_typ
	when "iframe"
		content_tag(:iframe, nil, :src  => video_url, :width => @width, :height => @height, :controls =>'' )
	else
		content_tag(:video, tag(:source, :src => video_url, :type => "video/mp4" ) , :width => @width, :height => @height, :controls =>'' )
	end
    end
end

