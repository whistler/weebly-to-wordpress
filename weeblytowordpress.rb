#!/usr/bin/env ruby

require_relative 'importer'
require_relative 'exporter'

CACHEDIR = "site/"
file = open('sitemap.xml')

if ARGV.count != 4
	print 'usage: ./weeblytowordpress.rb <weebly_site> <wp_site> <wp_username> <wp_password> [fetch=true]'
end

weebly_site, wp_site, username, password, fetch = ARGV
fetch = true if fetch.nil?
importer = WeeblyToWordpress::Importer.new
posts = importer.import(weebly_site, fetch)
exporter = WeeblyToWordpress::Exporter.new
exporter.export(posts, weebly_site, wp_site, username, password)