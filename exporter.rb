require 'rubypress'
require 'ruby-progressbar'
require 'uri'
require 'sequel'
require 'pry'
require 'mime/types'
require 'nokogiri'
require 'xmlrpc/client'

module WeeblyToWordpress
	class Exporter

		def initialize()
			@images = {}
		end

		def export(posts, old_site, new_site, username, password)
			@old_site = old_site
			@blog = Rubypress::Client.new(:host => new_site, 
				:username => username, :password => password)
			pbar = ProgressBar.create(title: "Uploading", total: posts.count)
			posts.each do |post|
				create_post(post)
				pbar.increment
			end
		end

		def create_post(post)
			post[:content] = extract_content(post[:content])
			content = add_images(post)
			@blog.newPost(:blog_id => "your_blog_id", :content => { 
				:post_status => "publish", 
				:post_date => DateTime.parse(post[:modified]), 
				:post_content => content, 
				:post_title => post['og:title'] })
		end

		def extract_content(post_html)
			doc = Nokogiri::HTML(post_html)
			return doc.css("#wsite-content").to_s
		end

		def upload_or_find_file(image)
			url = @images[image]
			if url.nil? 
				name = File.basename(image)

				#remove params
				matches = /(.*)\?/.match(name)
				name = matches[1] unless matches.nil?
				
				mime = MIME::Types.type_for(name).first.content_type
				bits = XMLRPC::Base64.new(File.open(image).read())
				data = {:name => name, :bits => bits, 
						:overwrite => false}
				response = @blog.uploadFile(data: data)
				url = response["url"]
				@images[image] = url
			end
			return url
		end

		def add_images(post)
			content = post[:content]
			doc = Nokogiri::HTML(content)
			doc.css('img').each do |img|
				img_url = img_url = img.attributes["src"].value
				cached_img = img_url.gsub(@old_site, "").gsub("http://","")
				cached_img = File.join(CACHEDIR, cached_img)
				new_url = upload_or_find_file(cached_img)
				content = content.gsub(img_url, new_url)
			end
			return content
		end
	end
end