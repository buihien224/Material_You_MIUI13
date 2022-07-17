#!/bin/bash

recp="java -jar bin/apktool.jar"

if [[ $1 == "-n" ]]; then
	cp -rf bin/sample "source/monet.$2"
	sed -i "s@sample@$3@g" "source/monet.$2/AndroidManifest.xml"

else

	if [[ -d apk_out ]]; then
		rm -rf apk_out/*
	else mkdir apk_out
	fi

	$recp if bin/*apk

	for i in $(ls source); do
		echo "Recomplie : $i"
		$recp b source/$i -o "apk_out/$i.apk"
		if [[ -f "apk_out/$i.apk" ]]; then
			echo "Signing : $i"
			apksigner sign --ks bin/miuivs --ks-pass pass:linkcute "apk_out/$i.apk"
			rm -rf "apk_out/$i.apk.idsig"
		else
			echo "$i : Failure"
		fi
	done

	if [ -z "$(ls -A apk_out)" ]; then
	   echo "Empty output"
	else

	   echo "Making magisk module"
	   cp -rf module module_temp
	   mkdir -p module_temp/system/product/overlay/
	   cp -rf apk_out/. module_temp/system/product/overlay/
	   sed -i "s@abcxyz@$(date +"%H%M%d%m")@g" module_temp/module.prop
	   sed -i "s@bhlnk@"github-$1"@g" module_temp/module.prop
	   rm -rf apk_out
	fi
fi

