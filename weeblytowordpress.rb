#!/usr/bin/env ruby

require_relative 'importer'
require_relative 'exporter'

CACHEDIR = "site/"
file = open('sitemap.xml')

if ARGV.count != 2
	print 'usage: ./weeblytowordpress.rb <oldsite> <newsite> <username> <password>'
end

oldsite, newsite, username, password = ARGV

importer = WeeblyToWordpress::Importer.new
posts = importer.import(oldsite)
exporter = WeeblyToWordpress::Exporter.new
exporter.export(posts, oldsite, newsite, username, password)