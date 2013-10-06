#!/usr/bin/env ruby

require_relative 'importer'

CACHEDIR = "site/"
file = open('sitemap.xml')

if ARGV.count != 2
	print 'usage: ./weeblytowordpress.rb <site> <database connection>'
end

site, db = ARGV

importer = WeeblyToWordpress::Importer.new
data = importer.import(site)