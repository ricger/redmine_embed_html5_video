Redmine::Plugin.register :redmine_embed_html5_video do
  name 'Embed Html5 Video plugin'
  author 'Richard Gertis'
  description 'Embeds attachment videos, video URLs, Youtube or Vimeo videos. Usage (as macro): video(ID|URL|YOUTUBE_URLi|VIMEO_URL). Updated to HTML5'
  version '0.0.3'
  url 'https://github.com/ricger/redmine_embed_html5_video'
  author_url 'https://github.com/ricger/redmine_embed_html5_video'
end

Redmine::WikiFormatting::Macros.register do
    desc "Wiki embed html5 video:\n\n" +
	"{{video(file [, width] [, height], [, controls])}}"
    macro :video do |obj, args|
        width      = args[1].gsub(/\D/,'') if args[1]
        height     = args[2].gsub(/\D/,'') if args[2]
	controls   = args[3]
        width    ||= 400
        height   ||= 300
	if (controls == '0' || controls == 0 || controls == nil || controls == 'false') 
		controls = nil
	else 
		controls = true
	end 
	

        attachment = obj.attachments.find_by_filename(args[0]) if obj.respond_to?('attachments')
	
	if attachment
            file_url = url_for(:only_path => false, :controller => 'attachments', :action => 'download', :id => attachment, :filename => attachment.filename)
        else
            file_url = args[0].gsub(/<.*?>/, '').gsub(/&lt;.*&gt;/,'')
        end
 	
	case file_url
	# check for youtube-URL, extract youtubeID and assign to local variable {youtubeID}
	when /^https?:\/\/((www\.)?youtube\.com\/(watch\?([\w\d\=]*\&)*v=|embed\/){1}|youtu\.be\/)(?<youtubeID>[\w\d\-]*)((\&|\/)[\w\d\=\-]*)*$/
		if !controls
			yt_params="?controls=0"
		else
			yt_params="?nix=#{controls}"
		end
		video_url = "https://www.youtube.com/embed/#{$LAST_MATCH_INFO['youtubeID']}#{yt_params}"
		embed_typ = "iframe"
	# check for vimeo-URL...
        when /^https?:\/\/(www\.)?vimeo\.com\/(?<vimeoID>[\d]*)((\D)[\w\d\=\-]*)*$/
		# hiding video-controls not possible at vimeo.com
                video_url = "https://player.vimeo.com/video/#{$LAST_MATCH_INFO['vimeoID']}"
                embed_typ = "iframe"
	else
		# Currently, there are 3 supported video formats for the <video> element: MP4, WebM, and Ogg
		# http://www.w3schools.com/tags/tag_video.asp
		# Check also http://www.html5rocks.com/en/tutorials/video/basics/
		video_url = file_url
		embed_typ = "video"
		case file_url
		when /^https?:\/\/(.*\/)?(?<video_name>.*)\.(?<video_format>mp4|ogg|webm)(\?.*)?$/
			mime_type = "video/#{$LAST_MATCH_INFO['video_format']}"
		else
			video_url = "unknown filetype: #{$LAST_MATCH_INFO['video_format']}"
		end
	end

	case embed_typ
	when "iframe"
		content_tag(:iframe, nil, :src  => video_url, :width => width, :height => height )
	else
		content_tag(:video, tag(:source, :src => video_url, :type => mime_type ) ,  :width => width, :height => height, :controls => controls )
	end
    end
end

