#
# Copyright (c) 2019-2021, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

import os
import subprocess
import tempfile
import shutil
import unittest
import check_dupe_classes
import platform

FAKE_CONT1 = "This is some class bytecode"
FAKE_CONT2 = "This is some other class bytecode"
ALLOWLIST_PATH = ""

class TestVerifyDupeClasses(unittest.TestCase):

    def setUp(self):
        global ALLOWLIST_PATH
        self.tempdir = tempfile.mkdtemp("TestVerifyConflict")
        ALLOWLIST_PATH = self._write_allowlist_file()

    def tearDown(self):
        shutil.rmtree(self.tempdir)

    def test_single_jar_with_two_unique_class(self):
        classes_dir = self._create_fake_class("MyClass.class", "classes",
                                              "com/salesforce", FAKE_CONT1)
        classes_dir = self._create_fake_class("MyClass2.class", "classes",
                                              "com/salesforce", FAKE_CONT2)

        jar_dir = os.path.join(self.tempdir, "inner_jar2")
        os.makedirs(jar_dir)
        jar_file = self._create_jar("myjar.jar", jar_dir, classes_dir)

        springbootjar = self._create_springboot_jar("sb2.jar", jar_dir)

        check_dupe_classes.run(springbootjar, ALLOWLIST_PATH, None)

    def test_two_jars_with_duplicate_class__same_content(self):
        classes_dir1 = self._create_fake_class("MyClass.class", "classes1",
                                               "com/salesforce", FAKE_CONT1)
        # make the jar more interesting: add another class
        self._create_fake_class("MyClass2.class", "classes1", "com/salesforce",
                                FAKE_CONT2)
        classes_dir2 = self._create_fake_class("MyClass.class", "classes2",
                                               "com/salesforce", FAKE_CONT1)

        jar_dir = os.path.join(self.tempdir, "inner_jar3")
        os.makedirs(jar_dir)
        jar_file1 = self._create_jar("myjar1.jar", jar_dir, classes_dir1)
        jar_file2 = self._create_jar("myjar2.jar", jar_dir, classes_dir2)

        springbootjar = self._create_springboot_jar("sb3.jar", jar_dir)

        check_dupe_classes.run(springbootjar, ALLOWLIST_PATH, None)

    def test_two_jars_with_duplicate_class__different_content(self):
        classes_dir1 = self._create_fake_class("MyClass.class", "classes1",
                                               "com/salesforce", FAKE_CONT1)
        classes_dir2 = self._create_fake_class("MyClass.class", "classes2",
                                               "com/salesforce", FAKE_CONT2)

        jar_dir = os.path.join(self.tempdir, "inner_jar4")
        os.makedirs(jar_dir)
        jar_file1 = self._create_jar("myjar1.jar", jar_dir, classes_dir1)
        jar_file2 = self._create_jar("myjar2.jar", jar_dir, classes_dir2)

        springbootjar = self._create_springboot_jar("sb4.jar", jar_dir)

        with self.assertRaises(Exception) as ctx:
            check_dupe_classes.run(springbootjar, ALLOWLIST_PATH, None)

        self.assertIn("Found duplicate classes", str(ctx.exception))

    def test_two_jars_with_duplicate_class_allowlisted__different_content(self):
        classes_dir1 = self._create_fake_class("MyClass.class", "classes1",
                                               "com/salesforce", FAKE_CONT1)
        classes_dir2 = self._create_fake_class("MyClass.class", "classes2",
                                               "com/salesforce", FAKE_CONT2)

        jar_dir = os.path.join(self.tempdir, "inner_jar5")
        os.makedirs(jar_dir)
        jar_file1 = self._create_jar("myjar20.jar", jar_dir, classes_dir1)
        jar_file2 = self._create_jar("myjar21.jar", jar_dir, classes_dir2)

        springbootjar = self._create_springboot_jar("sb5.jar", jar_dir)

        check_dupe_classes.run(springbootjar, ALLOWLIST_PATH, None)


    # HELPERS

    def _create_jar(self, name, jar_dir, classes_dir):
        jar_file = os.path.join(jar_dir, name)
        self._run("jar cf %s %s" % (jar_file, "."), cwd=classes_dir)
        assert os.path.exists(jar_file)
        return jar_file

    def _create_springboot_jar(self, name, innerjar_dir):
        jar_file = os.path.join(self.tempdir, name)
        self._run("jar cf %s %s" % (jar_file, "."), cwd=innerjar_dir)
        assert os.path.exists(jar_file)
        return jar_file

    def _create_fake_class(self, name, root_classes_dir, package, content):
        classes_dir = os.path.join(self.tempdir, root_classes_dir)
        package_dir = os.path.join(classes_dir, package)
        if not os.path.exists(package_dir):
            os.makedirs(package_dir)
        class_file = os.path.join(package_dir, name)
        with open(class_file, "w") as f:
            f.write(content)
        return classes_dir

    def _write_index_file(self, jar_files):
        index_file_path = os.path.join(self.tempdir, "classes.txt")
        print(index_file_path)
        with open(index_file_path, "wb") as f:
            for jar_file in jar_files:
                f.write(("%s%s\n" % (check_dupe_classes.JARNAME_PREFIX, jar_file)).encode())
                f.write(self._run("unzip -l %s" % jar_file))
        return index_file_path

    def _write_allowlist_file(self):
        allowlist_file_path = os.path.join(self.tempdir, "allowlist.txt")
        with open(allowlist_file_path, "w") as f:
                f.write(self.tempdir+ "/myjar20.jar\n")
                f.write(self.tempdir+ "/myjar21.jar\n")
        return allowlist_file_path

    def _run(self, cmd, cwd=None):
        if not cwd:
            cwd = self.tempdir
        output = subprocess.Popen(cmd, cwd=cwd, shell=True, stdout=subprocess.PIPE).stdout.read()
        return output


if __name__ == '__main__':
    unittest.main()
