#!/bin/bash

# This assumes the Alfresco Development environment. If running outside of that, you have two options:
# 1) set the a WORK_DIR environment variable with the location to the code, or 
# 2) run this script from the root of your project's code

# Ensure the basic preconditions are met
if [ "$CURRENT_PROJECT" == "" ] ; then
   # No Dev Env project found - checking WORK_DIR.
   if [ "$WORK_DIR" == "" ] ; then
      WORK_DIR=`pwd`
   fi
else
   # Assume Alfresco Dev Env project structure.
   PROJECT_DIR="$DEV_HOME/projects/$CURRENT_PROJECT"

   # We'll set the WORK_DIR below after importing any settings files.
fi

# THis is the name of the external file used to load any settings that override the defaults
SETTINGS="l10n.properties"
SETTINGS_LOADED=false


# Default settings. Imported settings can override any of these on a per project basis:

# To add support for a new language, just add it to this space separated list:
SUPPORTED_LANGUAGES="de es fr it ja nl zh_CN ru nb pt_BR"

#If the search path is modified to include any top level directory other than projects, enterpriseprojects or modules, then the check in install_files() should be modifed
#When individual files, be sure to added them as file-name*.properties to ensure you match all locales and default files.
MESSAGE_SEARCH_PATH="projects/slingshot/config projects/slingshot/source/web/js/alfresco projects/web-client/config/alfresco/messages projects/repository/config/alfresco/messages projects/repository/config/alfresco/workflow projects/web-framework-commons projects/data-model/config/alfresco/messages projects/remote-api/config/alfresco/templates/webscripts enterpriseprojects/repository/config/alfresco/enterprise/form-service*.properties enterpriseprojects/repository/config/alfresco/workflow/hybrid-workflow-model-messages*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/process/process-messages*.properties modules/wcmquickstart/wcmquickstartwebsite/config/alfresco/messages/common*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/message/wcmqs*.properties modules/wcmquickstart/wcmquickstartmodule/config/alfresco/module/org_alfresco_module_wcmquickstart/model/website-model*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/site-webscripts/org/alfresco/components/wcmqs/wcmqs-document-translations.get*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/messages/wcmquickstart*.properties modules/wcmquickstart/wcmquickstartsharemodule/config/alfresco/site-webscripts/org/alfresco/components/dashlets/wcmqs.get*.properties enterpriseprojects/*/config/alfresco/enterprise/messages/*.properties enterpriseprojects/remote-api/config/alfresco/enterprise/webscripts/org/alfresco/enterprise/repository/admin"

EXCLUDED_FILES="privatemodules/thor/config/alfresco/subsystems/RemoteAlfrescoTransformer/default/remote-transformer.properties privatemodules/thor/source/test-resources/rest-api-test.properties privatemodules/thor-share/config/alfresco/module/org_alfresco_module_cloud_share/file-mapping.properties privatemodules/thor-share/config/alfresco/site-webscripts/org/alfresco/cloud/core/customizations/components/rules/config/rule-config-condition.get.properties projects/data-model/config/alfresco/messages/dictionary-messages.properties projects/remote-api/config/alfresco/templates/webscripts/org/alfresco/repository/audit/control.properties projects/repository/config/alfresco/messages/activity-list.properties projects/repository/config/alfresco/messages/content-service.properties projects/repository/config/alfresco/messages/jbpm-engine-messages.properties projects/repository/config/alfresco/messages/module-messages.properties projects/repository/config/alfresco/messages/patch-service.properties projects/repository/config/alfresco/messages/repoadmin-interpreter-help.properties projects/repository/config/alfresco/messages/schema-update.properties projects/repository/config/alfresco/messages/slingshot.properties projects/repository/config/alfresco/messages/tenant-interpreter-help.properties projects/repository/config/alfresco/messages/version-service.properties projects/repository/config/alfresco/messages/wcmapp-model.properties projects/repository/config/alfresco/messages/workflow-interpreter-help.properties projects/web-client/config/alfresco/messages/webclient-config-admin-interpreter-help.properties /alfresco-global.properties /log4j.properties /module.properties /cloud-authentication.properties .svn-base /target/"

#When Checking for untranslated words, ignore lines including these words (space seperated list):
# TODO: Handle strings containing only Variables better
IGNORED_STRINGS="date-format date-picker due-date help.example fullCalendar calendar.widget_config. imap.command_ fileservers.set.cifs fileservers.set.ftp d_dictionary.datatype.d_ content_filter_lang label.skype wcmqs.shortName wcmqs.get.properties:label.title url.help date.format header.networks.label ={0} ={3} cloud.title.test label.passwordHelp app.ios.install.link webclient.properties:date spaces.scripts.example.workflow.name templates.document.system_overview.name EXIF Temp cm_contentmodel.aspect.cm cm_contentmodel.association.cm alfresco/messages/system-messages.properties =DBID =Dublin =HTML =XML =IMAP ftp.trustStore ooojodconverter.field.jodconverter.officeHome PageLinkLabel= tinyPagination.template OOoJodConverter =Google =OpenOffice =Solr =Lucene label.addonsLink =URL label.shortVersion =ID config-feed.get.properties:label.limit help.url UTF-8 =FreeMarker left_qoute =OpenSearch =Alfresco =ms =Skype pagination.template={PreviousPageLink} webclient.properties:time_pattern webclient.properties:right_quote webclient.properties:wiki_reference_part2 header.logo pagination.template =Id panel.kb panel.no composite_condition_page_or =Sysadmin calendar.widget_config.my_label_year_suffix label.passwordHelp certificate.status.valid empty_message= empty.description header.license= form.required.fields.marker readme.template.title org.alfresco.profile.status-changed customise.compare-property-value.text socialPublish.confirm.link common.properties:tinymce_languages toolbar.get.properties:button.next toolbar.get.properties:button.previous view.get.properties:agenda.truncate.ellipsis =JMX no_data=-- =CIFS =FTP =NFS =SPP =WebDAV =FFMpeg"

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

#Tar or Zip? - used to generate the translated bundle
#PACKAGE_CMD="tar cvfz"
PACKAGE_CMD="zip"

#Install options - used to overlay the translated bundle
INSTALL_CMD="cp -Rv"

# EXTENSION is the var that contains the suffix added to the zip files when they're generated.
# It's set below because we need to do it after the svn/git check, which requires us to already know the WORK_DIR
# If you don't want to include the revision number in the extension you can override by uncommenting this:
# EXTENSION=
# In order that projects can customise the EXTENSION (whilst retaining the revision), we include a prefix here:
EXTENSION_PREFIX=""

# For legacy reasons we've got some built in overrides.
# TODO: export these.
if [[ $# -gt 1 ]]
then
   if [[ $1 = "--config-override" || $1 = "-c" ]]
   then
      if [ $2 = "CLOUD" ]
      then
         echo "Applying config override for Alfresco in the cloud"
         # MESSAGE_SEARCH_PATH="$MESSAGE_SEARCH_PATH privatemodules/thor privatemodules/thor-share"
         MESSAGE_SEARCH_PATH="$MESSAGE_SEARCH_PATH privatemodules/thor/config/alfresco/messages/ privatemodules/thor/config/alfresco/module/org_alfresco_module_cloud/email_templates/ privatemodules/thor/config/alfresco/workflow/ privatemodules/thor-share/config/alfresco/messages/ privatemodules/thor-share/config/alfresco/site-webscripts/"
         #SUPPORTED_LANGUAGES="fr de es it ja"
 
         SETTINGS_LOADED=true
         SETTINGS_LOCATION="hard coded CLOUD overrides"
      elif [ $2 = "PENTAHO" ]
      then
         echo "Applying config override for Pentaho project"
         MESSAGE_SEARCH_PATH="modules/pentaho-share/src/main/amp/config/alfresco/site-webscripts/org/alfresco/ modules/pentaho-share/src/main/amp/web/js/alfresco/pentaho/ pentaho-baserver/pentaho-solutions/src/main/resources/system/analyzer/resources/messages*.properties pentaho-baserver/baserver-webapp/src/main/resources/org/alfresco/ pentaho-baserver/pentaho-solutions/src/main/resources/system/pentaho-geo/resources/messages"
         WORK_DIR=$PROJECT_DIR/code
         EXCLUDED_FILES="$EXCLUDED_FILES /messages_supported_languages.properties"
 
         SETTINGS_LOADED=true
         SETTINGS_LOCATION="hard coded PENTAHO overrides"
      else
         echo "Config Override Unrecognised: $2"
         usage
         exit -1
      fi
      # Shift gets rid of the $1 param, so run it twice to remove both config override specific params and then continue as normal.
      shift
      shift
   fi
fi

loadSettings()
{
   echo "Loading settings from: $WORK_DIR"
   source $WORK_DIR/$SETTINGS
   SETTINGS_LOADED=true
   SETTINGS_LOCATION=$WORK_DIR/$SETTINGS
}

# Set the work directory (if it hasn't already been set) & load settings from it.
# Check a series of known paths. If it contains a $SETTINGS file assume that's the WORK_DIR and go no further
if [[ "$WORK_DIR" == "" ]]
then
   WORK_DIR=$PROJECT_DIR

   if [[ -f "$WORK_DIR/$SETTINGS" ]]
   then
      loadSettings
   
   elif [[ -d "$WORK_DIR/code" ]]
   then
      # This is used by RM, Pentaho and other module projects
      WORK_DIR=$WORK_DIR/code

      if [[ -f "$WORK_DIR/$SETTINGS" ]]
      then
         loadSettings
      
      elif [[ -d "$WORK_DIR/root" ]]
      then
         # This is default for Core Alfresco projects.
         WORK_DIR=$WORK_DIR/root

         if [[ -f "$WORK_DIR/$SETTINGS" ]]
         then
            loadSettings
         fi
      fi
   fi
elif [[ -f "./$SETTINGS" ]]
then
   loadSettings
fi

#Are we running against a git or an svn checkout? Default to SVN (as most projects are still in SVN)
isSVN=true
# Only run this if git is installed:
command -v git >/dev/null 2>&1;
if [[ $? -eq 0 ]]
then
   git -c $WORK_DIR rev-parse >/dev/null 2>&1;
   if [[ $? -eq 0 ]]
   then
      isSVN=false
   fi
fi

#Some Cygwin setups use a windows Cygwin which works with WORK_DIR, others need that converting to a Unix/Cygwin path
# TODO: fix this to use date for git, e.g. `date +%s`
if [[ "$isSVN" = true ]]
then
   REVISION=`svn info $WORK_DIR | grep Revision | cut -d" " -f2`

   if [[ $REVISION == "" ]]
   then 
      REAL_WORK_DIR=`cygpath $WORK_DIR`
      echo "CYGWIN: Converting WORK_DIR: $WORK_DIR to REAL_WORK_DIR: $REAL_WORK_DIR"
      REVISION=`svn info $WORK_DIR | grep Revision | cut -d" " -f2`

   fi

   echo "Working against revision: $REVISION"

   #Diff options (requires SVN):
   DIFF_CMD="svn diff --revision $2:$3"
   DIFF_FILE="$4/$2-$3.EN.diff"
   TEXT_FILE="$4/$2-$3.files.EN.txt"
else
   GIT_INFO=`git remote show origin | grep "Fetch"|cut -d" " -f5; git rev-parse --abbrev-ref HEAD ; git log -1 --pretty=format:"%h @ %ci"`
   REVISION=`date -u +"%Y-%m-%dT%H%M%S"`
   echo "Working on a Git project. Using date instead of svn revision number for file numbering: $REVISION"
fi

EXTENSION=$EXTENSION_PREFIX-rev$REVISION.zip

# Status
echo "SVN: $isSVN"
echo "Project Dir: $PROJECT_DIR"
echo "WORK_DIR: $WORK_DIR"
if [[ "$SETTINGS_LOADED" = true ]]
then
   echo "Project settings loaded from $SETTINGS_LOCATION"
else
   echo "Default settings used"
fi
echo "Message search path: $MESSAGE_SEARCH_PATH"

#Functions
usage()
{
   echo
   echo "Usage: l10n-bundle option [path|string] [encoding]"
   echo "   or: l10n-bundle diff [revision1] [revision2] [path]"
   echo
   echo Generates or installs resource bundles for UI properties files
   echo 
   echo OPTION:
   echo    $'\t' "install": will copy the language bundle from PATH to the appropriate place in current project
   echo    $'\t' "export": will save resource bundles for all supported languages to PATH
   echo    $'\t' "decode": will convert all properties files at PATH from unicode escaped ASCII to ENCODING
   echo    $'\t' "encode": will convert all properties files at PATH to unicode escaped ASCII from ENCODING
   echo    $'\t' "decode-string": will convert from a Unicode escaped string found in the properties files to the encoding specified
   echo    $'\t' "encode-string": will convert a string in the specified encoding to a Unicode escape string for pasting into properties files.
   echo    $'\t' "diff": produces a diff file of all changes to EN properties files between the two specified revisions. A list of files modified or added, but not deleted, is also produced. These are written to the directory specified in PATH.
   echo    $'\t' "count": shows a list of the number of files and number of strings translated for each language. If a PATH is specified, it'll check all properties files in that PATH, regardless of language, otherwise the projects default directory will be used and it'll sort them by language.
   echo    $'\t' "check": produces a report of the missing strings for each language and writes it to the supplied PATH.
   echo    $'\t' "check-encoding": checks to see if any of the files in either the supplied PATH or your working copy - if no path is supplied - are incorrectly encoded. Results printed to std out.
   echo    $'\t' 
   echo
   echo PATH:
   echo    $'\t' - the path to the directory
   echo    $'\t' NOTE:
   echo    $'\t'    $'\t' - For install, PATH must contain a projects directory and/or an enterpriseprojects directory otherwise it will abort.
   echo
   echo STRING: 
   echo    $'\t' - the string for encoding or decoding. Only used with decode-string or encode-string options
   echo
   echo ENCODING:
   echo    $'\t' - The encoding  of the input files - for encode mode - or output files - decode mode, taken from list of
   echo    $'\t'   encodings at: http://java.sun.com/j2se/1.5/docs/guide/intl/encoding.doc.html
   echo    $'\t' NOTE:
   echo    $'\t'    $'\t' - Use: "LATIN9" for European languages
   echo    $'\t'    $'\t' - Use: "UTF16" or "UTF8" for Japanese
   echo
   echo NOTES:
   echo    $'\t' Supported Languages are: $SUPPORTED_LANGUAGES and the default files are EN
   echo    $'\t' Property files are looked for in: $MESSAGE_SEARCH_PATH
   echo 
   echo CONFIGURATION:
   echo    $'\t' Multiple configuration settings can be specified.
   echo    $'\t' Any option may be preceeded by "--config-override project-name" if this is the case, then the settings from the profile with that project-name will be loaded instead of the default.
   echo    $'\t' Current projects with custom config are: "RM"
   echo    $'\t' Please see the "config_RM" function for an example of how project specific config can be added.
   echo
}

# This function returns a list of properties files contained within the project's MESSAGE_SEARCH_PATH.
# If a parameter is supplied, that parameter may either be
# a locale.
get_files()
{
   #echo "Finding Files using this filter: $1"
   if [[ $# -lt 1  ]]
   then
      # remove all files that have a supported locale set to return just the default
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -Ev \(${EXCLUDED_FILES// /\|}\) | grep -v -E _\(${SUPPORTED_LANGUAGES//\ /\|}\).properties
   elif [[ $1 = "all" ]]
   then
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -Ev \(${EXCLUDED_FILES// /\|}\)
   else
      # only return the files for the locale passed in
      find $MESSAGE_SEARCH_PATH -name '*.properties*' -print 2> /dev/null | grep -Ev \(${EXCLUDED_FILES// /\|}\) | grep _$1.properties
   fi
}

install_files()
{
   cd $1 > /dev/null
   echo "Installing from `pwd` to $WORK_DIR using $INSTALL_CMD"
   #Check DIR is correct.
   if [[ -d "projects" || -d "enterpriseprojects" || -d "modules" || -d "privatemodules" || -d "rm-share" ]]
   then
      # All translated properties files include an underscore, check for that before installing the bundle.
      if [[ `find . -name "*.properties" | grep -v "_" | wc -l` -eq 0 ]] 
      then 
         $INSTALL_CMD . "$WORK_DIR" > /dev/null
      else
         echo 
         echo "FAILURE: all or some of the properties files do not include a locale in: `pwd`"
         find . -name "*.properties" | grep -v "_"
         echo
      fi
   else
      echo 
      echo "FAILURE: Could not find projects or enterpriseprojects or modules directory in $1 - is the path correct?"
      echo
   fi
   #pipe the output to /dev/null to prevent the path being printed & distracting the user from the output or error.
   cd - > /dev/null
}

generate_files()
{
   cd $WORK_DIR/
   $PACKAGE_CMD $1/EN$EXTENSION `get_files`     
   for language in `echo "$SUPPORTED_LANGUAGES"`
   do   
      LANGUAGE=`echo $language |tr [:lower:] [:upper:]`
      $PACKAGE_CMD $1/$LANGUAGE$EXTENSION `get_files "$language"`
   done 
   cd - > /dev/null
}

decode_files()
{
   echo "Decoding files at: $1 from unicode into encoding $2"
   # This command reverse encodes all the files makes them UTF16 so that accented chars and 
   # Japanese characters don't appear as unicode escape strings
   find $1 -name "*.properties" -print|xargs -n1 -I % native2ascii -reverse -encoding $2 % %

}

encode_files()
{
   echo "Encoding files at: $1 from encoding $2 to unicode"
   # this command encodes all files (from LATIN9) to ASCII:
   # find . -name "*.properties" -print|xargs -n1 -I % native2ascii -encoding LATIN9 % %
   find $1 -name "*.properties" -print|xargs -n1 -I % native2ascii -encoding $2 % %
   
}

do_diff()
{
   get_files | xargs -n1 -I % $DIFF_CMD % 
}

diff_files()
{
   #Note: This only works for SVN projects...
   echo "Querying SVN for differences, this may take some time..."
   # It does take time. It runs a seperate svn diff command on each file after searching the tree for relevent files.

   # SET UP THE DIRECTORY - get_files (used by do_diff) likes to be in a known location - it prevents having to prefix the search string with the full path!   
   cd $WORK_DIR/
   
   # DIFF
   # Finds all EN properties files, passes them to $DIFF_CMD and writes the output (and errors) to the log file.
   # Errors are written to enable us to determine missing files later in the script. These should perhaps be written elsewhere, though to ensure the .diff stays valid.
   echo "Writing differences to: $DIFF_FILE"
   do_diff &> $DIFF_FILE
   
   # Parse the Diff file and extract summary data from it:
   echo "Writing list of files that have changed to $TEXT_FILE"

   ## SUMMARY TXT FILE
   # Add title, overwritting already existing file (file name should be unique)
   echo "SUMMARY OF CHANGES" > $TEXT_FILE
   echo "" >> $TEXT_FILE
   
   ## WORD COUNT
   # This gets all added or modified lines from the diff file
   WORD_COUNT=`cat $DIFF_FILE | grep -e "^+[A-z]"|cut -d= -f2|wc -w`
   echo "$WORD_COUNT words have been added or modified"
   echo "Words added or modified between these revisions: $WORD_COUNT" >> $TEXT_FILE
   echo "" >> $TEXT_FILE
   
   ## MODIFIED FILES
   #This finds all files mentioned in diff file (prefixed with Index:) and then determines if there have been any changes in the path.
   # If they have they,re shown in brackets, so find bracket contents, remove from results if it contains revision info instead (which means path hasn't changed) 
   # then tidy the output by removing unwanted text decoration. 
   echo "Modified Files" >> $TEXT_FILE
   echo "" >> $TEXT_FILE
   cat $DIFF_FILE | grep -A3 "Index: " | cut -d"(" -f2 | cut -d")" -f1 | grep -v "revision " | grep -v -e "===" | cut -d: -f2 | cut -d" " -f2 >> $TEXT_FILE 
   #"
   echo "" >> $TEXT_FILE
      
   ## NEW FILES
   #new files generate an error (they can't be found in first revision), parse that error and output to seperate list
   echo "Writing list of files that have been added"
   echo "" >> $TEXT_FILE
   echo "New Files" >> $TEXT_FILE
   grep "svn: Unable to find" $DIFF_FILE |cut -d"'" -f2 >> $TEXT_FILE
   #'

   ## CLEAN UP
   cd - > /dev/null
}

count()
{
   echo "Counting Files:"
   echo -n "English"; get_files | wc -l
   for language in `echo "$SUPPORTED_LANGUAGES"`
   do
      echo -n "$language:"; get_files "$language" | wc -l 
   done

   echo "Counting Strings:"
   echo -n "English: "; grep "=" `get_files` | wc -l
   for language in `echo "$SUPPORTED_LANGUAGES"`
   do
      echo -n "$language:"; grep "=" `get_files "$language"` | wc -l 
   done
}

check()
{
   tmpENfile=$1/EN-check-$REVISION.tmp
   tmpENfile2=$1/EN-check-$REVISION.tmp2
   tmpENfile3=$1/EN-check-$REVISION.tmp3

   reportFile=$1/localisation-check-report-$REVISION.txt

   echo "Running check report. Report file will be stored at: $reportFile"

   echo -n "en."

   echo "Localisation Report:" > $reportFile # clobber file to start with
   echo "" >> $reportFile
   echo "Generated: `date` by `whoami`" >> $reportFile

   if [[ "$isSVN" = true ]]
   then
      echo `svn info | grep "URL:"` >> $reportFile
   else
      echo "Git Origin URL, branch, latest commit hash and commit timestamp:"
      echo $GIT_INFO >> $reportFile
   fi

   echo "Revision: $REVISION" >> $reportFile
   echo "Supported Locales: $SUPPORTED_LANGUAGES" >> $reportFile
   echo "" >> $reportFile

   #TODO: Ignore this with git.
   if [[ "$isSVN" = true ]]
   then
      if [[ `svn status | grep "_*.properties" | wc -l` -ne 0 ]]
      then
         echo "WARNING: There are uncommited changes to localised properties files" >> $reportFile
         echo "" >> $reportFile
      fi
   fi

   #remove all comments with the hash & any line that contains an equals that is escaped.
   grep "=" `get_files` | grep -v ".properties:#" | grep -v "'/="  > $tmpENfile2
   echo -n "."

   #ensure consistent line endings for comparison
   dos2unix $tmpENfile2 2> /dev/null

   cat $tmpENfile2 | cut -d= -f1 | grep -v "<" | sed 's/[ ]*$//' | sort | uniq -u > $tmpENfile
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
      tmpLNfile6=$1/$language-check-$REVISION.tmp6
      tmpLNfile7=$1/$language-check-$REVISION.tmp7

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
      cat $tmpLNfile3 | cut -d= -f1| grep -v "<" | sed 's/[ ]*$//'  | sort | uniq -u > $tmpLNfile
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
      echo "Language Bundle Check report: " > $outputLNfile
      echo "" >> $outputLNfile
      echo "Revision: $REVISION" >> $outputLNfile
      echo "Language: $language" >> $outputLNfile

      
      # Generate list of unique lines:
      # We determine which file the unique line appears in by catting both together and then finding duplicate lines.
      cat $tmpLNfile $tmpENfile | sort | uniq -u >> $tmpLNfile6
      echo -n "."

      # Lines that exist only in English file.
      echo "Strings missing from the translated bundle" >> $outputLNfile
      echo "-------------------------------------------------------------------------" >> $outputLNfile
      cat $tmpLNfile6 $tmpENfile | sort | uniq -d > $tmpLNfile7 # Clobber tmp output file
      cat $tmpLNfile7 >> $outputLNfile
      echo "" >> $outputLNfile
      echo -n "."      

      echo "Files containing strings missing from translated bundle (number of missing strings)" >> $outputLNfile
      echo "-------------------------------------------------------------------------" >> $outputLNfile
      cat $tmpLNfile7 | cut -d: -f1 | sort | uniq -c  >> $outputLNfile
      echo "" >> $outputLNfile
      echo -n "."

      # Lines that exist only in localised version:
      echo "Strings that appear in translated bundle, but not the English one (these should be removed)" >> $outputLNfile
      echo "(this includes strings that appear in the bundle from files that are now in the EXCLUDED list)" >> $outputLNfile
      echo "-------------------------------------------------------------------------" >> $outputLNfile
      cat $tmpLNfile $tmpLNfile6 | sort | uniq -d > $tmpLNfile7 # Clobber tmp output file.
      cat $tmpLNfile7 >> $outputLNfile
      echo "" >> $outputLNfile
      echo -n "."      

      echo "Files containing strings that only appear in translated bundle (number of redundant strings)" >> $outputLNfile
      echo "-------------------------------------------------------------------------" >> $outputLNfile
      cat $tmpLNfile7 | cut -d: -f1 | sort | uniq -c  >> $outputLNfile
      echo "" >> $outputLNfile
      echo -n "."

      # - add a list of strings that appear twice or more in the bundle (duplicate string definitions)
      echo "Duplicated string definitions in $language:" >> $outputLNfile
      echo "-------------------------------------------------------------------------" >> $outputLNfile
      cat $tmpLNfile3 | cut -d= -f1| grep -v "<" | sed 's/[ ]*$//' | sort | uniq -d >> $outputLNfile
      echo "" >> $outputLNfile
      echo -n "."
      
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
      for excluded in `echo $IGNORED_STRINGS ${!strings}` 
      do
         cat $tmpLNfile4 | grep -v "$excluded" > $tmpLNfile5
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
      rm $tmpLNfile $tmpLNfile2 $tmpLNfile3 $tmpLNfile4 $tmpLNfile5 $tmpLNfile6 $tmpLNfile7 2> /dev/null
   done
   
   echo "."
   rm $tmpENfile $tmpENfile2 $tmpENfile3 2> /dev/null

   cat $reportFile
}

count_bundle()
{
   echo "Counting properties files and strings in: $1"
   echo -n "Files: "; find $1 -name "*.properties*" -print | wc -l
   echo -n "Strings: "; grep "=" `find $1 -name "*.properties*" -print` | wc -l
}

check_encoding()
{
   # Expected results are:
   # Shift-JIS: Non-ISO extended-ASCII text 
   # Unicode: ASCII text, with CRLF line terminators
   # UTF-8: UTF-8 Unicode text
   # Latin 9: ISO-8859
   
   if [[ $# -lt 1 ]]
   then
      files=`get_files all`
   else
      files=`find $1 -name "*.properties*" -print`
   fi 
   
   echo "Checking files in $1 are ASCII encoded:"
   # "HTML", "TI-XX Graphing Calculator" and "CCP4 Electron Density Map" are false positives that are returned. They're actually ASCII files.
   for file in $files
   do
      file $file | grep -v ": ASCII" | grep -v "HTML" | grep -v "TI-XX Graphing Calculator" | grep -v "CCP4 Electron Density Map"
   done
   
   # Encoding errors typically show up as question marks in the files.
   echo "Checking Files for encoding errors:"
   
   for file in $files
   do
      grep -H "??" $file
   done
   
}

clean()
{
   # Sometimes hidden characters creep in to the start of files
   # this is particularly a problem for emails as it prevents them being sent as HTML emails
   # a simple way to fix this is to pass the files through dos2unix
   echo "Cleaning files using dos2unix"
   find . -name "*.properties*" | xargs -n 1 dos2unix;
}

# Parse input params and run the right tool
if [[ $# -lt 2   ]] #at least 2 params are required - option and path, except for the options below:
then
   if [ $1 = "files" ]
   then
      cd $WORK_DIR
      get_files
      cd - > /dev/null
   elif [ $1 = "count" ]
   then
      count
   elif [ $1 = "check-encoding" ]
   then
      cd $WORK_DIR
      check_encoding
      cd - > /dev/null
   elif [ $1 = "clean" ]
   then
      clean
   else
      usage
      exit -1
   fi
elif [ $1 = "install" ]
then
   install_files $2
elif [ $1 = "export" ]
then
   generate_files $2
elif [ $1 = "decode" ]
then
   decode_files $2 $3
elif [ $1 = "encode" ]
then
   encode_files $2 $3
elif [ $1 = "decode-string" ]
then
   echo $2 | native2ascii -reverse -encoding $3
elif [ $1 = "encode-string" ]
then
   echo $2 | native2ascii -encoding $3
elif [[ $1 = "diff" && $4 != "" ]]
then
   if [ isSVN = true ]
   then 
      diff_files
   else
      echo "Unable to diff files for a Git repo"
   fi
elif [ $1 = "check" ]
then
   cd $WORK_DIR
   check $2
   cd - > /dev/null
elif [ $1 = "count" ]
then
   count_bundle $2
elif [ $1 = "check-encoding" ]
then
   check_encoding $2
elif [ $1 = "files" ]
then
   cd $WORK_DIR
   get_files "$2"
   cd - > /dev/null
else
   usage
   exit -1
fi
