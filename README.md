# name:		ca-harvester.sh
#
# features:	creates a random  C l o u d A p p  short URL (cl . ly/xxxx) 
#		checks that URL, if it finds content it downloads it
#		renames the file, preserving the url suffix in the filename
#		limits overall size of download in MB (default 100MB)
#
# usage:	chmod +x ca-havester.sh
#		./ca-harvester.sh
#		(optional) edit ca-harvester.sh and modify SIZE_LIMIT
#
# disclosure:	I disclosed this vulnerability to the company that runs this 
#		service on Thursday, 1 Dec 2011 at 23:09:20 -0600  The code
#		was released Wednesday, 15 February 2012 at 20:09:15 -0600
#
# license:	this is open source software released under the Simplified BSD
#		License (http://www.opensource.org/licenses/bsd-license.php)
#
# inspiration:	@dcurtis http://cargo.dustincurtis.com.s3.amazonaws.com/
#		c l o u d a p p - rou let te.html 
#		C l o u d A p p  banned that webapp, but did nothing more for 
#		users' privacy. The goal of this project was to prove that. 
#
# ran_quote:	there were more but now drops
#
# contact:	phil at philcryer dot com
