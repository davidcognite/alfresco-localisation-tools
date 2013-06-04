#!/bin/bash

if [[ $# -lt 1 ]]
then
    echo "USAGE $0 path/to/write/reports.txt [additional_locales]"
    exit -1
fi

# In this standalone version, instead of using SVN revision, use the timestamp to create unique files.
REVISION=`date +%s`

#If the search path is modified to include any top level directory other than projects, enterpriseprojects or modules, then the check in install_files() should be modifed
#When individual files, be sure to added them as file-name*.properties to ensure you match all locales and default files.
MESSAGE_SEARCH_PATH="projects/slingshot/config projects/slingshot/source/web/js/alfresco projects/web-client/config/alfresco/messages projects/repository/config/alfresco/messages projects/repository/config/alfresco/workflow projects/web-framework-commons projects/data-model/config/alfresco/messages projects/remote-api/config/alfresco/templates/webscripts enterpriseprojects/repository/config/alfresco/enterprise/form-service*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/process/process-messages*.properties modules/wcmquickstart/wcmquickstartwebsite/config/alfresco/messages/common*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/message/wcmqs*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/model/website-model*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/site-webscripts/org/alfresco/components/wcmqs/wcmqs-document-translations.get*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/messages/wcmquickstart*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/site-webscripts/org/alfresco/components/dashlets/wcmqs.get*.properties enterpriseprojects/*/config/alfresco/enterprise/messages/*.properties"
# to add support for a new language, just add it to this space separated list:
SUPPORTED_LANGUAGES="de es fr it ja nl zh_CN ru nb_NO $2"

EXCLUDED_FILES="privatemodules/thor/config/alfresco/module/org_alfresco_module_cloud/log4j.properties privatemodules/thor/config/alfresco/module/org_alfresco_module_cloud/module.properties privatemodules/thor/config/alfresco/subsystems/Authentication/alfrescoCloud/cloud-authentication.properties privatemodules/thor/config/alfresco/subsystems/RemoteAlfrescoTransformer/default/remote-transformer.properties privatemodules/thor/source/test-resources/publicapi/alfresco-global.properties privatemodules/thor/source/test-resources/remote-transform/alfresco-global.properties privatemodules/thor/source/test-resources/log4j.properties privatemodules/thor/source/test-resources/rest-api-test.properties privatemodules/thor-share/config/alfresco/module/org_alfresco_module_cloud_share/file-mapping.properties privatemodules/thor-share/config/alfresco/module/org_alfresco_module_cloud_share/module.properties privatemodules/thor-share/config/alfresco/site-webscripts/org/alfresco/cloud/core/customizations/components/rules/config/rule-config-condition.get.properties projects/data-model/config/alfresco/messages/dictionary-messages.properties projects/remote-api/config/alfresco/templates/webscripts/org/alfresco/repository/audit/control.properties projects/repository/config/alfresco/messages/activity-list.properties projects/repository/config/alfresco/messages/content-service.properties projects/repository/config/alfresco/messages/jbpm-engine-messages.properties projects/repository/config/alfresco/messages/module-messages.properties projects/repository/config/alfresco/messages/patch-service.properties projects/repository/config/alfresco/messages/repoadmin-interpreter-help.properties projects/repository/config/alfresco/messages/schema-update.properties projects/repository/config/alfresco/messages/slingshot.properties projects/repository/config/alfresco/messages/tenant-interpreter-help.properties projects/repository/config/alfresco/messages/version-service.properties projects/repository/config/alfresco/messages/wcmapp-model.properties projects/repository/config/alfresco/messages/workflow-interpreter-help.properties projects/web-client/config/alfresco/messages/webclient-config-admin-interpreter-help.properties"
#When Checking for untranslated words, ignore lines including these words (space seperated list):
# TODO: Handle strings containing only Variables better
IGNORED_STRINGS="date-format date-picker due-date help.example fullCalendar calendar.widget_config. imap.command_ fileservers.set.cifs fileservers.set.ftp d_dictionary.datatype.d_ content_filter_lang label.skype wcmqs.shortName wcmqs.get.properties:label.title url.help date.format header.networks.label ={0} ={3} cloud.title.test label.passwordHelp app.ios.install.link webclient.properties:date spaces.scripts.example.workflow.name templates.document.system_overview.name EXIF Temp cm_contentmodel.aspect.cm cm_contentmodel.association.cm alfresco/messages/system-messages.properties =DBID =Dublin =HTML =XML =IMAP ftp.trustStore ooojodconverter.field.jodconverter.officeHome PageLinkLabel= tinyPagination.template OOoJodConverter =Google =OpenOffice =Solr =Lucene label.addonsLink =URL label.shortVersion =ID config-feed.get.properties:label.limit help.url UTF-8 =FreeMarker left_qoute =OpenSearch =Alfresco =ms =Skype pagination.template={PreviousPageLink} webclient.properties:time_pattern webclient.properties:right_quote webclient.properties:wiki_reference_part2 header.logo pagination.template =Id panel.kb panel.no composite_condition_page_or =Sysadmin calendar.widget_config.my_label_year_suffix label.passwordHelp certificate.status.valid empty_message= empty.description header.license= form.required.fields.marker readme.template.title org.alfresco.profile.status-changed customise.compare-property-value.text socialPublish.confirm.link common.properties:tinymce_languages toolbar.get.properties:button.next toolbar.get.properties:button.previous view.get.properties:agenda.truncate.ellipsis =JMX no_data=--"

IGNORED_LN_STRINGS_de="=N/A =Tag =Workflow =Wiki =Start wcmquickstart.properties:dashlet.wcmqs.description =Import =Name =Post =Server =Home =Login =Single-Sign-On =Information =Premium =UI =Icon =Imap =Site =Audio =Album =Channel =Recording =Engineer =Genre =Sample cm_autoVersion =Fax =IM cm_lockIsDeep =Name =Status =Person =Forum =Root =Container =Store =Domain =Port =Host =WINS =Passphrase =Logout =Repository .tag-management =Avatar =Backup =Exe =Version =Blog =Link siteDashboard.title =Schema =Build =Label =Revision =Manager =Browser =Authority =Node imagemagick pdf2swf tooltip.site =Activiti =JBPM =Info =Post =Test =RSS =Index =OK =CMIS =Dashlets =Layout =Text link.siteDashboard =Details =GB =MB =KB =Administrator Sandbox"

IGNORED_LN_STRINGS_es="=N/A =Audio =Wiki =Error =Email =Configurable =Script =Album =Fax =Base =Versionable =Host =General =Avatar label.no =Blog =Residual =Dashlets action.accept =Host =GB =KB =Local =MB no=No =Roles =Variables"

IGNORED_LN_STRINGS_fr="=Article =Finance =Contact =Action =N/A =Exception =Tag =Confirmation =Message =Information =Aspect =Description =Type =Script =Transition =Configurable =Workflow =Configurations =Audio =Album =Genre =Orientation =Notes =Alias =Forum =Discussion =Base =Port =Keystore =Application =Site =Photo =Documents =Version =Extension =Blog =Wiki =Options =Destination =Minute =Archive =Agenda =Avatar =Logo =Association =Index =Collection =parent =Quote =OK =Dashlets =add =Public =Expresion =Page =Notification =copies =Standad =Condition =Information =Variables tinymce_languages =Parent =Transformations =Document =Fax =Latitude =Longitude =Quota wcmquickstart.properties:dashlet.wcmqs.description =Local =Format =Navigation =Structure"

IGNORED_LN_STRINGS_it="=N/A =Tag =Workflow =Wiki =Blog =Exe =Query =Download =Server =Home =Password =Login =Reset account.class.PAID_BUSINESS.display-name=Premium label_signed =Configurable app_uifacets =Audio =Album =Fax =Quota =Discussable =Forum =Root =Referenceable =Base =Host =Password =Keystore =Passphrase =Repository =Avatar =Mimetype =No =OK =Backup =Logout =Schema =Build =Manager =Script =Browser =Runtime =Activiti =Info =Layout =File =Directory =GB =KB =MB =Check =Server =LIVE =JMX =Quota =Reset =Sandbox =Output"

IGNORED_LN_STRINGS_ja="=OK label.copyright=&copy; =GB =KB =MB =Blog =Exe =IM"

# Languages not yet analysed
IGNORED_LN_STRINGS_nl=""
IGNORED_LN_STRINGS_zh_CN=""
IGNORED_LN_STRINGS_ru=""
IGNORED_LN_STRINGS_nb_NO=""

get_files()
{
   #echo "Finding Files using this filter: $1"
   if [[ $# -lt 1  ]]
   then
      # remove all files that have a supported locale set to return just the default
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -v ".svn-base" | grep -v -E _\(${SUPPORTED_LANGUAGES//\ /\|}\).properties
   elif [[ $1 = "all" ]]
   then
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -v ".svn-base"
   else
      # only return the files for the locale passed in
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -v ".svn-base" | grep _$1.properties
   fi
}

tmpENfile=$1/EN-check-$REVISION.tmp
tmpENfile2=$1/EN-check-$REVISION.tmp2
tmpENfile3=$1/EN-check-$REVISION.tmp3

reportFile=$1/localisation-check-report-$REVISION.txt

echo "Running check report. Report file will be stored at: $reportFile"

echo -n "en."

echo "Localisation Report:" > $reportFile # clobber file to start with
echo "" >> $reportFile
echo "Generated: `date` by `whoami`" >> $reportFile
echo "Supported Locales: $SUPPORTED_LANGUAGES" >> $reportFile
echo "" >> $reportFile

echo -n "."

#remove all comments with the hash & any line that contains an equals that is escaped.
grep "=" `get_files` | grep -v ".properties:#" | grep -v "'/="  > $tmpENfile2
echo -n "."

#ensure consistent line endings for comparison
dos2unix $tmpENfile2 2> /dev/null

cat $tmpENfile2 | cut -d= -f1 | grep -v "<" | sed 's/[ ]*$//' > $tmpENfile
# generate a list of: 
#  - english strings in the format: {filename minus extension}:{property}
enFileCount=`get_files | wc -l`
enStringCount=`cat $tmpENfile | sort | uniq | wc -l`
echo "en files:" $enFileCount " strings:" $enStringCount >> $reportFile
echo -n "."

#write duplicated EN strings to file for checking:
cat $tmpENfile | sort | uniq -d > $1/$REVISION-EN-check.txt

for language in `echo "$SUPPORTED_LANGUAGES"`
do

  echo "----------------------------" >> $reportFile
  echo "Analysis for $language:" >> $reportFile
  echo  >> $reportFile

  echo -n "$language."

  tmpLNfile=$1/$language-check-$REVISION.tmp
  tmpLNfile2=$1/$language-check-$REVISION.tmp2
  tmpLNfile3=$1/$language-check-$REVISION.tmp3
  tmpLNfile4=$1/$language-check-$REVISION.tmp4
  tmpLNfile5=$1/$language-check-$REVISION.tmp5

  outputLNfile=$1/$REVISION-$language-check.txt
  #  - strings for each LN in format: {filename minus extension minus locale}@{property}
  # cut removes the actual translation
  # grep -v "<" removes any lines with HTML in - fixes a bug where lines of HTML wrap and match the grep for "=", but shouldn't.
  # the first sed removes trailing spaces
  # second sed removes the locale from the input filename to make direct comparisons easier
  # all comments are then removed.
  # changes to the greps and pipes here need to be reflected above when $tmpENfile is generated
  # adds /dev/null to list of files, so there is always at least one file to search, otherwise pipe breaks.
  # also now pipes to a grep -v to remove a line with an equals on that should be ignored!
  grep "=" /dev/null `get_files "$language"` | grep -v "/=" > $tmpLNfile2

  #ensure consistent line endings for comparison
  dos2unix $tmpLNfile2 2> /dev/null

  cat $tmpLNfile2 | sed "s/_$language.properties/.properties/g" | grep -v ".properties:#" > $tmpLNfile3
  cat $tmpLNfile3 | cut -d= -f1| grep -v "<" | sed 's/[ ]*$//'  > $tmpLNfile
  echo -n "."

  # Write Status Line to Output
  lnFileCount=`get_files "$language" | wc -l`
  lnStringCount=`cat $tmpLNfile | sort | uniq | wc -l`
  echo "$language files missing:" `expr $enFileCount - $lnFileCount` >> $reportFile
  echo "$language strings missing:" `expr $enStringCount - $lnStringCount` >> $reportFile
  echo >> $reportFile
  echo "Totals:" $lnFileCount "files, with" $lnStringCount "strings" >> $reportFile
  echo -n "."
  
  # Write title, clobbering any existing file with the same name (filename is based on rev, so should be safe to clobber)
  echo "String Differences for $language:" > $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  #  - combine the files, then print the lines that appear only once.
  cat $tmpLNfile $tmpENfile | sort | uniq -u >> $outputLNfile
  echo "" >> $outputLNfile
  echo -n "."      

  # - add a summary of files with missing lines      
  echo "Files containing missing strings in $language (number of missing strings)" >> $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  cat $outputLNfile | grep ".properties" | cut -d: -f1 | sort | uniq -c  >> $outputLNfile
  echo "" >> $outputLNfile
  echo -n "."

  # - add a list of strings that appear twice or more in the bundle (duplicate string definitions)
  echo "Duplicated string definitions in $language:" >> $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  cat $tmpLNfile | sort | uniq -d >> $outputLNfile
  echo "" >> $outputLNfile
  echo -n "."
  
  # TODO:
  # The above will match files that exist in the translated bundle that do not exist in the English, so I should probably add an extra grep.
  # for each result:
  #  - if it matches in EN file: add to list of properties missing from LN
  #  - else add to list of extra (unnecessary) properties in LN


  # Find strings with non duplicated quotes
  echo "Strings with variables and single quotes:" >> $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  cat $tmpLNfile3 | grep "}" |sed -n "/[^']'[^']/p" | grep -v ".properties.ftl"> $tmpLNfile4
  echo "Strings with missing double quotes:" `cat $tmpLNfile4 | wc -l` >> $reportFile
  echo -n "."
  cat $tmpLNfile4 >> $outputLNfile
  echo "" >> $outputLNfile

  # Find strings that are still in English:
  
  # input needs running through "uniq" first to filter out strings that are duplicated (either in EN or $language) otherwise these will be incorrectly flagged as untranslated strings.
  # input and output files can't match as output file is clobbered before input file has finished streaming.
  cat $tmpLNfile3 | sort | uniq > $tmpLNfile5
  mv $tmpLNfile5 $tmpLNfile3
  cat $tmpENfile2 | sort | uniq > $tmpLNfile5
  mv $tmpLNfile5 $tmpENfile2

  echo -n "."
  cat $tmpLNfile3 $tmpENfile2 | sort | uniq -d > $tmpLNfile4

  echo -n "."
  strings=IGNORED_LN_STRINGS_$language
  for excluded in `echo $EXCLUDED_FILES $IGNORED_STRINGS ${!strings}` 
  do
     cat $tmpLNfile4 | grep -v "$excluded" > $tmpLNfile5
     # echo "Looking for: $excluded, found lines without it:" `cat $tmpLNfile5|wc -l`
     mv $tmpLNfile5 $tmpLNfile4
  done

  # When the EN value is blank (i.e. there is nothing after the =), the translated language is allowed to also be blank.

  echo -n "."
  cat $tmpLNfile4 | grep -v -E "\=$" > $tmpLNfile5
  mv $tmpLNfile5 $tmpLNfile4

  echo "Strings matching the English:" `cat $tmpLNfile4 | wc -l` >> $reportFile

  echo "Strings remaining in English in $language:" >> $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  cat $tmpLNfile4 >> $outputLNfile
  echo "" >> $outputLNfile


  # Check to see if there are any obvious encoding errors (uniscaped characters missing the leading slash):
  # the reg exp here matches unicode patterns with a "u" followed by at least one number - it will intentionally miss unicode sequences
  # starting with a letter because they're rather obscure (two usages at last count) I couldn't find a way to match them but not match
  # valid words like "succeeded" and "essay" which are more common. Thankfully references to Bono's band are rare as well.
  echo -n "."
  cat $tmpLNfile2 | grep -i -E "[^\\]u[0-9]{1}" > $tmpLNfile4

  echo "Strings with incorrectly escaped unicode:" >> $outputLNfile
  echo "-------------------------------------------------------------------------" >> $outputLNfile
  cat $tmpLNfile4 >> $outputLNfile
  echo "" >> $outputLNfile

  echo "Strings with incorect Unicode:" `cat $tmpLNfile4 | wc -l` >> $reportFile      

  echo "See $outputLNfile for full details">> $reportFile
  rm $tmpLNfile $tmpLNfile2 $tmpLNfile3 $tmpLNfile4 $tmpLNfile5 2> /dev/null
done

echo "."
rm $tmpENfile $tmpENfile2 $tmpENfile3 2> /dev/null

cat $reportFile