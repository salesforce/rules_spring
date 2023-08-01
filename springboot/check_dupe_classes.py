#
# Copyright (c) 2019-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

from collections import defaultdict
import hashlib
import os
import sys
import zipfile
import tempfile


def _check_for_duplicate_classes(springbootzip_filepath, ignorelisted_jars, output_filepath):
    """
    Prints error message and returns True if duplicate classes were found,
    false otherwise.

    Jars in the ignorelisted_jars list are excluded from the check.
    """

    # this will be set to True if any duplicate classes are found, that are not
    # contained by any jar in the ignorelist
    found_illegal_duplicates = False
    # this set will contain the jars that contain the violaters
    dupe_containing_jars = set()
    # list of paths of classes that are duped and have different hashes
    # use each string entry as a key into the class_catalog dict
    dupe_classes = []
    dupe_message_lines = ""

    # dict that maps the path to a class to all jars (as list) it was found in,
    #   and the hash for each appearance
    # for example:
    # com/acme/common/HostUtil.class ->
    # [
    #   { bazel-out/.../foolib.jar, 5807cc49dfbda8dd937de3b33a885409 },
    #   { bazel-out/.../blahlib.jar, 5807cc49dfbda8dd937de3b33a885409 }
    # ]
    class_catalog = defaultdict(list)

    # Starting the search....
    # iterate through the springboot jar file, and find inner jars,
    # open each inner jar and catalog each .class file found
    try:
        springbootzip = zipfile.ZipFile(springbootzip_filepath)
    except zipfile.BadZipFile:
        # this error happened to me when my computer ran out of disk space during a build
        result = "Spring Boot dupe detection has failed for %s because the generated jar file is corrupt, please delete this file.\n" % springbootzip_filepath
        print(result)
        _write_result_to_output_file(output_filepath, result)
        return True

    sprintbootzipentries = springbootzip.infolist()
    for springbootzipentry in sprintbootzipentries:
        if springbootzipentry.filename.endswith(".jar"):
            jar_path = springbootzipentry.filename
            innerjar = springbootzip.open(springbootzipentry.filename)

            # create a temporary copy of the inner jar as a file on disk
            innerjar_binarycontent = innerjar.read()
            innerjar_tmp_fileondisk = tempfile.TemporaryFile()
            innerjar_tmp_fileondisk.write(innerjar_binarycontent)
            # initialize a ZipFile object using the temporary copy
            innerjar_zip = zipfile.ZipFile(innerjar_tmp_fileondisk)
            innerjar_zipentries = innerjar_zip.infolist()

            for innerjar_zipentry in innerjar_zipentries:
                innerjar_zipentry_path = innerjar_zipentry.filename
                if innerjar_zipentry_path.endswith(".class"):
                    if innerjar_zipentry_path.endswith("module-info.class"):
                        continue
                    class_bytes = innerjar_zip.read(innerjar_zipentry_path)
                    digest = hashlib.md5(class_bytes).hexdigest()

                    # now check if we have seen this class before
                    other_locations = class_catalog[innerjar_zipentry_path]
                    for other_location in other_locations:
                        other_digest = other_location[1]
                        if other_digest != digest:
                            jar_base = os.path.basename(jar_path)
                            other_jar_base = os.path.basename(other_location[0])
                            this_is_a_dupe = False
                            # we fail as a dupe if both jars are not in the ignorelist
                            # we could be nicer and only fail if one of the jars is not in the ignorelist?
                            if jar_base not in ignorelisted_jars:
                                dupe_containing_jars.add(jar_base)
                                found_illegal_duplicates = True
                                this_is_a_dupe = True
                            if other_jar_base not in ignorelisted_jars:
                                dupe_containing_jars.add(other_jar_base)
                                found_illegal_duplicates = True
                                this_is_a_dupe = True
                            if this_is_a_dupe:
                                dupe_message_lines += "  class %s\n" % (innerjar_zipentry_path)
                                dupe_message_lines += "    jar %s hash %s\n" % (jar_base, digest)
                                dupe_message_lines += "    jar %s hash %s\n" % (other_jar_base, other_digest)

                    class_catalog_entry = (jar_path, digest)
                    class_catalog[innerjar_zipentry_path].append(class_catalog_entry)

            # end innerzipentries for loop
            innerjar_tmp_fileondisk.close()

    if found_illegal_duplicates:
      result = "Spring Boot packaging has failed for %s because multiple copies of the same class, but with different hashes, were found:\n" % springbootzip_filepath
      result += dupe_message_lines
      result += "You should eliminate the conflicting dependencies, or if that is not possible you can add these jars to the dupeclassescheck_ignorelist file:\n"
      for ignorelist_candidate in dupe_containing_jars:
          result += "   %s\n" % ignorelist_candidate
      print(result)
      _write_result_to_output_file(output_filepath, result)

    return found_illegal_duplicates

def _parse_ignorelisted_jars_file(ignorelist_file):
    """
    Reads the ignorelist.txt file and returns the jars as a set.
    File format: each line in the file is the name of a jar, like:
      foo.jar
      bar.jar
    """
    ignorelisted_jars = set()

    if ignorelist_file != None:
        with open(ignorelist_file, "r") as lines:
            for line in lines:
                line = line.strip()
                if len(line) == 0 or line.startswith("#"):
                    continue
                # cannot use the whole jar path as it is different for generated jars on linux and mac
                # this logic might need to change if two jars with the same name are part of the ignorelist
                jar = os.path.basename(line)
                ignorelisted_jars.add(jar)

    #if len(ignorelisted_jars) > 0:
    #    print("Springboot duplicate class checker ignorelisted jars:")
    #    for ignorelisted_jar in ignorelisted_jars:
    #        print("  %s" % ignorelisted_jar)

    return ignorelisted_jars

def _write_result_to_output_file(output_filepath, result):
    if output_filepath != None:
      f = open(output_filepath, "a")
      f.write(result)
      f.close()

def run_with_ignorelist(springbootzip_filepath, ignorelisted_jars, output_filepath):
    found_illegal_duplicates = _check_for_duplicate_classes(springbootzip_filepath, ignorelisted_jars,
        output_filepath)
    if found_illegal_duplicates:
        raise Exception("Found duplicate classes in the packaged springboot jar")
    else:
        _write_result_to_output_file(output_filepath, "SUCCESS")
    return found_illegal_duplicates

def run(springbootzip_filepath, ignorelist_file, output_filepath):
    """
    Iterates through a Spring Boot jar and looks for classes in inner jars. If the same
    class (package name + class name) appears more than once, verify that the .class files
    have the same hash code. If there is a conflict, this invocation will fail with an error.
    If both jars are listed in the ignorelist, the conflict will be ignored.
    """
    ignorelisted_jars = _parse_ignorelisted_jars_file(ignorelist_file)
    run_with_ignorelist(springbootzip_filepath, ignorelisted_jars, output_filepath)

if __name__ == "__main__":
    # arg1  path to the spring boot jar file (required)
    # arg2  path to the text file containing the jars to ignore as sources of dupes (optional)
    # arg3  outputfile (optional, will contain "SUCCESS" if the check passed, or the list of errors)
    ignorelist_file = None
    if len(sys.argv) > 2:
      ignorelist_file = sys.argv[2]
      if ignorelist_file == "no_ignorelist":
          ignorelist_file = None

    output_file = None
    if len(sys.argv) > 3:
      output_file = sys.argv[3]

    run(sys.argv[1], ignorelist_file, output_file)
