#!/bin/bash

## download.sh -- Download Joomla and CiviCRM

###############################################################################

git_cache_setup "https://github.com/joomla/joomla-cms.git" "$CACHE_DIR/joomla/joomla-cms.git"
git clone "$CACHE_DIR/joomla/joomla-cms.git" "$WEB_ROOT"

[ -z "$CMS_VERSION" ] && CMS_VERSION=3.2.1
pushd "$WEB_ROOT" >> /dev/null
  git checkout "$CMS_VERSION"

  ## Submitted PR to include cli/install.php in core -- https://github.com/joomla/joomla-cms/pull/2764
  ## For the moment, we need to add it ourselves
  if [ ! -f "cli/install.php" ]; then
    cp "$SITE_CONFIG_DIR/cli-install.php" "cli/install.php"
  fi

  ## TODO: Checkout Civi's code...
  cvutil_mkdir "$PRIVATE_ROOT" "$PRIVATE_ROOT/src"
  git clone ${CACHE_DIR}/civicrm/civicrm-joomla.git    -b "$CIVI_VERSION" src/civicrm
  git clone ${CACHE_DIR}/civicrm/civicrm-core.git      -b "$CIVI_VERSION" src/civicrm/admin/civicrm
  git clone ${CACHE_DIR}/civicrm/civicrm-packages.git  -b "$CIVI_VERSION" src/civicrm/admin/civicrm/packages

  git_set_hooks civicrm-joomla      src/civicrm                      "../admin/civicrm/tools/scripts/git"
  git_set_hooks civicrm-core        src/civicrm/admin/civicrm                      "../tools/scripts/git"
  git_set_hooks civicrm-packages    src/civicrm/admin/civicrm/packages          "../../tools/scripts/git"

  pushd src/civicrm/admin >> /dev/null
    #ln -s admin.civicrm.php civicrm.php
    mv admin.civicrm.php civicrm.php
  popd >> /dev/null

  ## usage: cvutil_link <to> <from>
  function cvutil_link() {
    from="$2"
    to="$1"
    cvutil_mkdir $(dirname "$to")
    pushd $(dirname "$to") >> /dev/null
      # ln -s "$from" $(basename "$to")
      mv "$from" $(basename "$to")
    popd >> /dev/null
  }
  cvutil_link plugins/user/civicrm                   ../../src/civicrm/admin/plugins/civicrm
  cvutil_link plugins/quickicon/civicrmicon          ../../src/civicrm/admin/plugins/civicrmicon
  cvutil_link plugins/system/civicrmsys              ../../src/civicrm/admin/plugins/civicrmsys
  cvutil_link administrator/components/com_civicrm   ../../src/civicrm/admin 
  cvutil_link components/com_civicrm                    ../src/civicrm/site

popd >> /dev/null
