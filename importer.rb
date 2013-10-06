require 'open-uri'
require 'uri'
require 'xmlsimple'
require 'nokogiri'
require 'fileutils'
require 'ruby-progressbar'
require 'pry'

module WeeblyToWordpress

	class Importer

		def get_sitemap(site)
			@site = site
			sitemappath = URI.join(site, '/sitemap.xml')
			download_file(sitemappath, 'sitemap.xml')
			file = open ('sitemap.xml')
			sitemap = XmlSimple.xml_in(file)
			pages = sitemap["url"].map{|loc| {location: loc["loc"].first, modified: loc["lastmod"].first}}
		end

		def import(site)
			sitemap = get_sitemap(site)
			pbar = ProgressBar.create(title: "Downloading", total: sitemap.count)

			pages = sitemap.map do |page|
				import_page(page)
				pbar.increment
			end
		end

		def import_page(page)
			page_html = get_page(page, false)
			save_images(page_html)
			{location: page[:location], modified: page[:modified]}
		end

		def download_file(from, to)
			begin
				FileUtils.mkdir_p(File.dirname(to))
				File.open(to, "wb") do |saved_file|
					open(from) do |read_file|
						saved_file.write(read_file.read)
					end
				end
			rescue Exception => e
				puts "Error downloading file: " + from.to_s
				puts e.message
			end
		end

		def get_page(page, cached = false)
			filename = page[:location].gsub(SITE, "")
			filename = File.join(CACHEDIR, filename)
			if cached 
				return open(filename)
			else
				return download_and_cache(page, filename)
			end
		end

		def download_and_cache(page, filename)
			file = open(page[:location])
			page_html = file.read
			# create directory if required
			
			File.open(filename, 'w') {|f| f.write(page_html) }
			save_images(page_html)
			return page_html
		end

		def save_images(content)
			doc = Nokogiri::HTML(content)
			doc.css('img').each do |img|
				img_url = img.attributes["src"].value
				save_url = img_url.gsub(SITE, "").gsub("http://","")
				img_url = insert_domain_if_missing(img_url)
				download_file(img_url, File.join(CACHEDIR, save_url))
			end
		end

		def insert_domain_if_missing(path)
			if path.index(@site) == nil
				return URI.join(@site, path)
			else
				return path
			end
		end

	end

end