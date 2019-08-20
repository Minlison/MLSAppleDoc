#mkdir ./docs
# ./appledoc ./  >> ./appdoclog.txt

pushd `dirname $0` > /dev/null
WORKING_PATH=`pwd`
PROJECT_PATH=$1

popd > /dev/null
declare -a DOC_THML_FILE_INDEXS
declare -a DOC_THML_MOUDLE_NAME_INDEXS
APPDOC_INDEX=0
DOC_HTML_INDEX_RELEATE_PATH=/docs/html/index.html
for file in `find ${PROJECT_PATH} -name AppledocSettings.plist`; do
	DOC_PATH=${file%/*}
    DOC_FILE_PATH=${DOC_PATH}/docs

    if [[ ! -d $DOC_FILE_PATH ]]; then
    	mkdir $DOC_FILE_PATH
    fi
    if [[ $DOC_PATH != $WORKING_PATH ]] || [[ ! -f $DOC_PATH/appledoc ]]; then
    	cp ./appledoc ${DOC_PATH}/appledoc
    	rsync -avr --copy-links --no-relative ./Templates $DOC_PATH
	    cd ${DOC_PATH}
		./appledoc ./ >>  ./appledoc.log
		HTML_INDEX_FILE=${DOC_PATH}${DOC_HTML_INDEX_RELEATE_PATH}
		if [[ -f ${HTML_INDEX_FILE} ]]; then
			DOC_INDEX_PATH_TMP=${DOC_PATH/${WORKING_PATH}/.}${DOC_HTML_INDEX_RELEATE_PATH}
			DOC_THML_FILE_INDEXS[APPDOC_INDEX]=$DOC_INDEX_PATH_TMP
			TEMP=${DOC_INDEX_PATH_TMP/${DOC_HTML_INDEX_RELEATE_PATH}/""}
			TEMP=${TEMP##*/}
			DOC_THML_MOUDLE_NAME_INDEXS[APPDOC_INDEX]=$TEMP
			let APPDOC_INDEX++
		fi
		rm -r -f ${DOC_PATH}/Templates
		rm ${DOC_PATH}/appledoc
		rm ${DOC_PATH}/appledoc.log
		cd ${WORKING_PATH}
	else
		./appledoc ./ >> ./appledoc.log
		DOC_INDEX_PATH_TMP=${DOC_PATH/${WORKING_PATH}/.}${DOC_HTML_INDEX_RELEATE_PATH}
		DOC_THML_FILE_INDEXS[APPDOC_INDEX]=$DOC_INDEX_PATH_TMP
		TEMP=${WORKING_PATH##*/}
		DOC_THML_MOUDLE_NAME_INDEXS[APPDOC_INDEX]=${TEMP}
		let APPDOC_INDEX++
    fi
done
# <a href="./">网络</a></li>
# <div id="content"><a href="PATH">NAME</a> </div>
if [[ -f "${WORKING_PATH}/index.html" ]]; then
	rm ${WORKING_PATH}/index.html
fi
INDEX_HTML_A_STR="<div id="content"><a href="PATH">NAME</a> </div>"
INDEX_HTML_TEMP_FILE=`cat ${WORKING_PATH}/Templates/index_temp.html`
INDEX_HTML_REPLACE_STR=""
APPDOC_INDEX=0
for MODULE_INDEX in ${DOC_THML_FILE_INDEXS[*]}; do
	TMP_HTML_A_STR=${INDEX_HTML_A_STR/PATH/\"${MODULE_INDEX}\"}
	TMP_HTML_A_STR=${TMP_HTML_A_STR/NAME/${DOC_THML_MOUDLE_NAME_INDEXS[APPDOC_INDEX]}}
	INDEX_HTML_REPLACE_STR=$INDEX_HTML_REPLACE_STR""$TMP_HTML_A_STR
	let APPDOC_INDEX++
done
INDEX_HTML_TEMP_FILE=${INDEX_HTML_TEMP_FILE/"{{Moudles}}"/${INDEX_HTML_REPLACE_STR}}

echo $INDEX_HTML_TEMP_FILE > ${WORKING_PATH}/index.html

unset DOC_THML_MOUDLE_NAME_INDEXS
unset DOC_THML_FILE_INDEXS

echo "-------Success---------"
