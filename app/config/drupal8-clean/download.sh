#!/bin/bash

## download.sh -- Download Drupal and CiviCRM

###############################################################################

git_cache_setup "http://git.drupal.org/project/drupal.git" "$CACHE_DIR/drupal/drupal.git"
#git_cache_setup "https://github.com/torrance/civicrm-drupal.git" "$CACHE_DIR/torrance/civicrm-drupal.git"
git_cache_setup "https://github.com/totten/civicrm-drupal.git" "$CACHE_DIR/totten/civicrm-drupal.git"

[ -z "$CMS_VERSION" ] && CMS_VERSION=8.0.x

MAKEFILE="${TMPDIR}/${SITE_TYPE}.make"
cat "$SITE_CONFIG_DIR/drush.make.tmpl" \
  | sed "s;%%CACHE_DIR%%;${CACHE_DIR};" \
  | sed "s;%%CIVI_VERSION%%;${CIVI_VERSION};" \
  | sed "s;%%CMS_VERSION%%;${CMS_VERSION};" \
  > "$MAKEFILE"

drush -y make --working-copy "$MAKEFILE" "$WEB_ROOT"

## FIXME: Patches that applied to core
rsync -va "$WEB_ROOT/modules/civicrm/drupal/core/./" "$WEB_ROOT/modules/civicrm/core/./"
pushd "$WEB_ROOT/modules/civicrm/core"
  patch -p1 < $SITE_CONFIG_DIR/core.diff
popd
