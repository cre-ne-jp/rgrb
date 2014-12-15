#!/bin/bash

for file in `ls -1`
do
	name=`echo $file |sed -e 's/.txt//'`
	yaml="../new/${name}.yaml"
	if [ -e ${yaml} ]
	then
		continue
	else
				cat << __EOS__ > ${yaml}
Name: ${name}
Description: ${name}
Date: `date +%Y-%m-%d`
Access: public
Author: sf
License: NONE
Body:
__EOS__

		cat ${file} \
			| sed -e 's/^/  - "/' \
			| sed -e 's/$/"/' \
			>> ${yaml}

	fi
	echo $file
	echo $name
	echo $yaml
	echo

done
