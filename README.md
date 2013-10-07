Weebly To Wordpress
===================

This is a tool to move Weebly sites to a new Wordpress blog. It reads the 
Weeblu sitemap from where it downloads each page as a post into Wordpress along
with any images it may have. 

Useage
------

Clone this tool to your computer:

    git clone git@github.com:whistler/weebly-to-wordpress.git
    cd weebly-to-wordpress
    chmod +x weeblytowordpress.rb

Run
	
	./weeblytowordpress.rb <weebly_site> <wp_site> <username> <password>


weebly_site - address of the weebly site e.g. "http://domain.com"
wp_site - address of the new Wordpress site e.g. "wordpresssite.com"
username - Wordpress username
password - Wordpress password
fetch - [Optional] set to false if already downloaded successfully - useful for
		debugging