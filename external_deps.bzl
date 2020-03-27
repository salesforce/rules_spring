#
# Copyright (c) 2017-9, salesforce.com, inc.
# All rights reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
#

#
# SAMPLE LIST OF DEPENDENCIES
# You will need to curate this list as your project requires it.
# During migration, you can use the 'mvn dependency:list' command to help you.
#
# TODO clean up this example workspace, there are way too many unused jars in here
# TODO add the version SHAs
#
def external_maven_jars():
    native.maven_jar(
        name = "aopalliance_aopalliance",
        artifact = "aopalliance:aopalliance:1.0",
    )

    native.maven_jar(
        name = "ch_qos_logback_logback_classic",
        artifact = "ch.qos.logback:logback-classic:1.2.3",
        sha256 = "fb53f8539e7fcb8f093a56e138112056ec1dc809ebb020b59d8a36a5ebac37e0",
        sha256_src = "480cb5e99519271c9256716d4be1a27054047435ff72078d9deae5c6a19f63eb",
    )

    native.maven_jar(
        name = "ch_qos_logback_logback_core",
        artifact = "ch.qos.logback:logback-core:1.2.3",
        sha256 = "5946d837fe6f960c02a53eda7a6926ecc3c758bbdd69aa453ee429f858217f22",
        sha256_src = "1f69b6b638ec551d26b10feeade5a2b77abe347f9759da95022f0da9a63a9971",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_core_jackson_annotations",
        artifact = "com.fasterxml.jackson.core:jackson-annotations:2.10.0",
        sha1 = "d88d5a15951ffcf8ddd5766f5170a45de537b284",
        sha1_src = "c8be836b340e2bf48c335cfd68765ab867cfd088",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_core_jackson_core",
        artifact = "com.fasterxml.jackson.core:jackson-core:2.10.0",
        sha1 = "4e2c5fa04648ec9772c63e2101c53af6504e624e",
        sha1_src = "379d754e510e25111a823428636be68773fc73c9",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_core_jackson_databind",
        artifact = "com.fasterxml.jackson.core:jackson-databind:2.10.0",
        sha1 = "1127c9cf62f2bb3121a3a2a0a1351d251a602117",
        sha1_src = "465988edbcc098cebd769e2ef110ce57661a27a4",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_dataformat_jackson_dataformat_yaml",
        artifact = "com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.10.0",
        sha1_src = "37cf9d562366d7b5ba28fb58d76ce982197e4cef",
        sha1 = "601e067f98b39f7991f66d99a3228044b9bf37c8",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_datatype_jackson_datatype_jdk8",
        artifact = "com.fasterxml.jackson.datatype:jackson-datatype-jdk8:2.10.0",
        sha1_src = "7e77a5a26a7a3e293faaf8d4391d8248406cbbe2",
        sha1 = "ac9b5e4ec02f243c580113c0c58564d90432afaa",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_datatype_jackson_datatype_jsr310",
        artifact = "com.fasterxml.jackson.datatype:jackson-datatype-jsr310:2.10.0",
        sha1 = "946bcb4b3ba9facfb338b1d48c2606225205a70c",
        sha1_src = "fa7bb655432311553c9717ef01d1b12989db4090",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_jaxrs_jackson_jaxrs_base",
        artifact = "com.fasterxml.jackson.jaxrs:jackson-jaxrs-base:2.10.0",
        sha1_src = "605260f4345ce9e80d0198d14623947208614199",
        sha1 = "7486902cc1db2d61cd0d7e4a763e9f2696c4b5a0",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_jaxrs_jackson_jaxrs_json_provider",
        artifact = "com.fasterxml.jackson.jaxrs:jackson-jaxrs-json-provider:2.10.0",
        sha1_src = "4be2bf58b4d07643ee6a34d2932cb639eda12a60",
        sha1 = "caafe32d349f4d4f402e64833342570bcff7fd08",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_module_jackson_module_jaxb_annotations",
        artifact = "com.fasterxml.jackson.module:jackson-module-jaxb-annotations:2.10.0",
        sha1 = "413345fa3798623890e29da9000246dcfa2c07da",
        sha1_src = "7ff4b8e723507ae36e59b3a2646f51166a7491e0",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_module_jackson_module_parameter_names",
        artifact = "com.fasterxml.jackson.module:jackson-module-parameter-names:2.10.0",
        sha1 = "d7ae5421ab27486429aeb878b7e3937544d9324a",
        sha1_src = "a52ab29f26c0b5b10b18584971ab78811e0dae0e",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_module_jackson_module_paranamer",
        artifact = "com.fasterxml.jackson.module:jackson-module-paranamer:2.10.0",
        sha1 = "4fc4ba10b328a53ac5653cee15504621c6b66083",
        sha1_src = "a9f08f5a2748cdc9968470b2df35c91d6b637d9f",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_module_jackson_module_scala_2_11",
        artifact = "com.fasterxml.jackson.module:jackson-module-scala_2.11:2.10.0",
        sha1_src = "a1cdc080eead909654b462b5411e63c01a5de663",
        sha1 = "582f2e2fc347b3de8d9a536df02750fc77515e88",
    )

    native.maven_jar(
        name = "com_fasterxml_classmate",
        artifact = "com.fasterxml:classmate:1.5.1",
        sha1_src = "504edac38ff03cc5ce1d0391abb1416ffad58a99",
        sha1 = "3fe0bed568c62df5e89f4f174c101eab25345b6c",
    )

    native.maven_jar(
        name = "com_github_ben_manes_caffeine_caffeine",
        artifact = "com.github.ben-manes.caffeine:caffeine:2.8.0",
    )

    native.maven_jar(
        name = "com_github_zafarkhaja_java_semver",
        artifact = "com.github.zafarkhaja:java-semver:0.9.0",
    )

    native.maven_jar(
        name = "com_google_code_gson_gson",
        artifact = "com.google.code.gson:gson:2.8.6",
    )

    native.maven_jar(
        name = "com_google_guava_guava",
        artifact = "com.google.guava:guava:26.0",
    )

    native.maven_jar(
        name = "com_google_inject_guice",
        artifact = "com.google.inject:guice:4.0",
    )

    native.maven_jar(
        name = "commons_beanutils_commons_beanutils",
        artifact = "commons-beanutils:commons-beanutils:1.9.4",
    )

    native.maven_jar(
        name = "commons_codec_commons_codec",
        artifact = "commons-codec:commons-codec:1.13",
    )

    native.maven_jar(
        name = "commons_collections_commons_collections",
        artifact = "commons-collections:commons-collections:3.2.2",
    )

    native.maven_jar(
        name = "commons_httpclient_commons_httpclient",
        artifact = "commons-httpclient:commons-httpclient:3.1",
    )

    native.maven_jar(
        name = "commons_io_commons_io",
        artifact = "commons-io:commons-io:2.6",
    )

    native.maven_jar(
        name = "commons_lang_commons_lang",
        artifact = "commons-lang:commons-lang:2.6",
    )

    native.maven_jar(
        name = "commons_logging_commons_logging",
        artifact = "commons-logging:commons-logging:1.2",
    )

    native.maven_jar(
        name = "io_dropwizard_metrics_metrics_core",
        artifact = "io.dropwizard.metrics:metrics-core:4.1.1",
    )

    native.maven_jar(
        name = "io_netty_netty",
        artifact = "io.netty:netty:3.10.1.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_buffer",
        artifact = "io.netty:netty-buffer:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_codec",
        artifact = "io.netty:netty-codec:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_codec_http",
        artifact = "io.netty:netty-codec-http:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_codec_http2",
        artifact = "io.netty:netty-codec-http2:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_codec_socks",
        artifact = "io.netty:netty-codec-socks:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_common",
        artifact = "io.netty:netty-common:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_handler",
        artifact = "io.netty:netty-handler:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_handler_proxy",
        artifact = "io.netty:netty-handler-proxy:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_resolver",
        artifact = "io.netty:netty-resolver:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_transport",
        artifact = "io.netty:netty-transport:4.1.43.Final",
    )

    native.maven_jar(
        name = "io_netty_netty_transport_native_epoll_linux_x86_64",
        artifact = "io.netty:netty-transport-native-epoll:jar:linux-x86_64:4.1.43.Final",
    )

    native.maven_jar(
        name = "javax_annotation_javax_annotation_api",
        artifact = "javax.annotation:javax.annotation-api:1.3.2",
    )

    native.maven_jar(
        name = "javax_inject_javax_inject",
        artifact = "javax.inject:javax.inject:1",
    )

    native.maven_jar(
        name = "javax_servlet_javax_servlet_api",
        artifact = "javax.servlet:javax.servlet-api:4.0.1",
    )

    native.maven_jar(
        name = "javax_validation_validation_api",
        artifact = "javax.validation:validation-api:2.0.1.Final",
    )

    native.maven_jar(
        name = "javax_ws_rs_javax_ws_rs_api",
        artifact = "javax.ws.rs:javax.ws.rs-api:2.1",
    )

    native.maven_jar(
        name = "jline_jline",
        artifact = "jline:jline:0.9.94",
    )

    native.maven_jar(
        name = "log4j_log4j",
        artifact = "log4j:log4j:1.2.17",
    )

    native.maven_jar(
        name = "net_bytebuddy_byte_buddy",
        artifact = "net.bytebuddy:byte-buddy:1.10.2",
    )

    native.maven_jar(
        name = "net_gescobar_jmx_annotations",
        artifact = "net.gescobar:jmx-annotations:1.0.1",
    )

    native.maven_jar(
        name = "net_sourceforge_findbugs_annotations",
        artifact = "net.sourceforge.findbugs:annotations:1.2.0",
    )

    native.maven_jar(
        name = "org_apache_commons_commons_lang3",
        artifact = "org.apache.commons:commons-lang3:3.9",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpclient",
        artifact = "org.apache.httpcomponents:httpclient:4.5.10",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpcore",
        artifact = "org.apache.httpcomponents:httpcore:4.4.12",
    )

    native.maven_jar(
        name = "org_apache_logging_log4j_log4j_api",
        artifact = "org.apache.logging.log4j:log4j-api:2.12.1",
        sha1 = "a55e6d987f50a515c9260b0451b4fa217dc539cb",
        sha1_src = "72dbe5460db61664f6bbfffb36665fa0bbe8e3ad",
    )

    native.maven_jar(
        name = "org_apache_logging_log4j_log4j_to_slf4j",
        artifact = "org.apache.logging.log4j:log4j-to-slf4j:2.12.1",
        sha1 = "dfb42ea8ce1a399bcf7218efe8115a0b7ab3788a",
        sha1_src = "163f67b05f1c43ebb5204b9ef5f1e6767360cff0",
    )

    native.maven_jar(
        name = "org_aspectj_aspectjrt",
        artifact = "org.aspectj:aspectjrt:1.9.4",
    )

    native.maven_jar(
        name = "org_aspectj_aspectjweaver",
        artifact = "org.aspectj:aspectjweaver:1.9.4",
    )

    native.maven_jar(
        name = "org_codehaus_jackson_jackson_core_asl",
        artifact = "org.codehaus.jackson:jackson-core-asl:1.9.13",
    )

    native.maven_jar(
        name = "org_codehaus_jackson_jackson_mapper_asl",
        artifact = "org.codehaus.jackson:jackson-mapper-asl:1.9.13",
    )

    native.maven_jar(
        name = "org_codehaus_janino_commons_compiler",
        artifact = "org.codehaus.janino:commons-compiler:2.7.8",
    )

    native.maven_jar(
        name = "org_codehaus_janino_janino",
        artifact = "org.codehaus.janino:janino:2.7.8",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_javax_websocket_client_impl",
        artifact = "org.eclipse.jetty.websocket:javax-websocket-client-impl:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_javax_websocket_server_impl",
        artifact = "org.eclipse.jetty.websocket:javax-websocket-server-impl:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_websocket_api",
        artifact = "org.eclipse.jetty.websocket:websocket-api:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_websocket_client",
        artifact = "org.eclipse.jetty.websocket:websocket-client:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_websocket_common",
        artifact = "org.eclipse.jetty.websocket:websocket-common:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_websocket_server",
        artifact = "org.eclipse.jetty.websocket:websocket-server:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_websocket_websocket_servlet",
        artifact = "org.eclipse.jetty.websocket:websocket-servlet:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_annotations",
        artifact = "org.eclipse.jetty:jetty-annotations:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_client",
        artifact = "org.eclipse.jetty:jetty-client:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_continuation",
        artifact = "org.eclipse.jetty:jetty-continuation:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_http",
        artifact = "org.eclipse.jetty:jetty-http:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_io",
        artifact = "org.eclipse.jetty:jetty-io:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_plus",
        artifact = "org.eclipse.jetty:jetty-plus:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_rewrite",
        artifact = "org.eclipse.jetty:jetty-rewrite:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_security",
        artifact = "org.eclipse.jetty:jetty-security:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_server",
        artifact = "org.eclipse.jetty:jetty-server:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_servlet",
        artifact = "org.eclipse.jetty:jetty-servlet:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_servlets",
        artifact = "org.eclipse.jetty:jetty-servlets:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_util",
        artifact = "org.eclipse.jetty:jetty-util:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_webapp",
        artifact = "org.eclipse.jetty:jetty-webapp:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_eclipse_jetty_jetty_xml",
        artifact = "org.eclipse.jetty:jetty-xml:9.4.22.v20191022",
    )

    native.maven_jar(
        name = "org_freemarker_freemarker",
        artifact = "org.freemarker:freemarker:2.3.29",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_external_aopalliance_repackaged",
        artifact = "org.glassfish.hk2.external:aopalliance-repackaged:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_external_javax_inject",
        artifact = "org.glassfish.hk2.external:javax.inject:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_class_model",
        artifact = "org.glassfish.hk2:class-model:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_config_types",
        artifact = "org.glassfish.hk2:config-types:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2",
        artifact = "org.glassfish.hk2:hk2:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_api",
        artifact = "org.glassfish.hk2:hk2-api:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_config",
        artifact = "org.glassfish.hk2:hk2-config:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_core",
        artifact = "org.glassfish.hk2:hk2-core:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_locator",
        artifact = "org.glassfish.hk2:hk2-locator:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_runlevel",
        artifact = "org.glassfish.hk2:hk2-runlevel:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_hk2_utils",
        artifact = "org.glassfish.hk2:hk2-utils:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_osgi_resource_locator",
        artifact = "org.glassfish.hk2:osgi-resource-locator:1.0.3",
    )

    native.maven_jar(
        name = "org_glassfish_hk2_spring_bridge",
        artifact = "org.glassfish.hk2:spring-bridge:2.5.0-b42",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_containers_jersey_container_servlet",
        artifact = "org.glassfish.jersey.containers:jersey-container-servlet:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_containers_jersey_container_servlet_core",
        artifact = "org.glassfish.jersey.containers:jersey-container-servlet-core:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_core_jersey_client",
        artifact = "org.glassfish.jersey.core:jersey-client:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_core_jersey_common",
        artifact = "org.glassfish.jersey.core:jersey-common:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_core_jersey_server",
        artifact = "org.glassfish.jersey.core:jersey-server:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_ext_jersey_entity_filtering",
        artifact = "org.glassfish.jersey.ext:jersey-entity-filtering:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_ext_jersey_spring3",
        artifact = "org.glassfish.jersey.ext:jersey-spring3:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_media_jersey_media_jaxb",
        artifact = "org.glassfish.jersey.media:jersey-media-jaxb:2.29.1",
    )

    native.maven_jar(
        name = "org_glassfish_jersey_media_jersey_media_json_jackson",
        artifact = "org.glassfish.jersey.media:jersey-media-json-jackson:2.29.1",
    )

    native.maven_jar(
        name = "org_hdrhistogram_HdrHistogram",
        artifact = "org.hdrhistogram:HdrHistogram:2.1.11",
    )

    native.maven_jar(
        name = "org_hibernate_hibernate_validator",
        artifact = "org.hibernate:hibernate-validator:5.4.3.Final",
    )

    native.maven_jar(
        name = "org_javassist_javassist",
        artifact = "org.javassist:javassist:3.24.0-GA",
    )

    native.maven_jar(
        name = "org_jboss_logging_jboss_logging",
        artifact = "org.jboss.logging:jboss-logging:3.4.1.Final",
        sha256 = "8efe877d93e5e1057a1388b2950503b88b0c28447364fde08adbec61e524eeb8",
        sha256_src = "8606e31150aa5370ab2ed79e21d13a9c0ba029380abf273a6bce15c92c2bce23",
    )

    native.maven_jar(
        name = "org_jvnet_tiger_types",
        artifact = "org.jvnet:tiger-types:1.4",
    )

    native.maven_jar(
        name = "org_mortbay_jasper_apache_el",
        artifact = "org.mortbay.jasper:apache-el:8.5.40",
    )

    native.maven_jar(
        name = "org_mpierce_metrics_reservoir_hdrhistogram_metrics_reservoir",
        artifact = "org.mpierce.metrics.reservoir:hdrhistogram-metrics-reservoir:1.1.0",
    )

    native.maven_jar(
        name = "org_objenesis_objenesis",
        artifact = "org.objenesis:objenesis:3.0.1",
    )

    native.maven_jar(
        name = "org_ow2_asm_asm",
        artifact = "org.ow2.asm:asm:7.1",
    )

    native.maven_jar(
        name = "org_ow2_asm_asm_commons",
        artifact = "org.ow2.asm:asm-commons:7.1",
    )

    native.maven_jar(
        name = "org_ow2_asm_asm_tree",
        artifact = "org.ow2.asm:asm-tree:7.1",
    )

    native.maven_jar(
        name = "org_slf4j_jcl_over_slf4j",
        artifact = "org.slf4j:jcl-over-slf4j:1.7.26",
    )

    native.maven_jar(
        name = "org_slf4j_jul_to_slf4j",
        artifact = "org.slf4j:jul-to-slf4j:1.7.26",
        sha256 = "0f3b6dfbfb261e3e2b71ea88574452f36c46fec016063439eb8f60083291918e",
        sha256_src = "8eebb18952ffd7267feff33658bd17470129aa2e36958176cbff716b7c7fe675",
    )

    native.maven_jar(
        name = "org_slf4j_log4j_over_slf4j",
        artifact = "org.slf4j:log4j-over-slf4j:1.7.26",
    )

    native.maven_jar(
        name = "org_slf4j_slf4j_api",
        artifact = "org.slf4j:slf4j-api:1.7.26",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot",
        artifact = "org.springframework.boot:spring-boot:2.2.1.RELEASE",
        sha1_src = "ac6d1512e0a854acf86b49a7fd0fecae04df4f08",
        sha1 = "3acb07ca9d6b968209a91aec6a7751f35bf22764",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_actuator",
        artifact = "org.springframework.boot:spring-boot-actuator:2.2.1.RELEASE",
        sha1 = "6f91f2e1f75b06388b65da9d3ae54164ad427922",
        sha1_src = "ec92a340bc384beb6a83b30e1d80a4594da6b90f",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_actuator_autoconfigure",
        artifact = "org.springframework.boot:spring-boot-actuator-autoconfigure:2.2.1.RELEASE",
        sha1 = "a6f0470d98405e7f2ca2ef418f2ef1b5f2695c53",
        sha1_src = "a109f93f7c3cb1493297e58fbcfd505748ef3920",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_autoconfigure",
        artifact = "org.springframework.boot:spring-boot-autoconfigure:2.2.1.RELEASE",
        sha1_src = "1d32cae2c4b6f09a22b32346320f1f0eeb1a3d48",
        sha1 = "1e45b519cc3b1de0b1ecee6eed6397c19ede95a2",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_configuration_processor",
        artifact = "org.springframework.boot:spring-boot-configuration-processor:2.2.1.RELEASE",
        sha1 = "95ba15dfcdde733c130a2813f9a5c93f7b9d01f0",
        sha1_src = "d23be822793fae472fef6af0c89202b6ba94d230",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_loader",
        artifact = "org.springframework.boot:spring-boot-loader:2.1.4.RELEASE",
        sha1 = "606e19c4c175399a5bad3e2e2f639ecee7ce3237",
        sha1_src = "0c325381230716538afb7a402eb090e367795074",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter",
        artifact = "org.springframework.boot:spring-boot-starter:2.2.1.RELEASE",
        sha1 = "5a4d687e6ffec805ce6320af7ca0b18798638200",
        sha1_src = "59509da18335073290c61afe3dc1ac7af4c54195",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_actuator",
        artifact = "org.springframework.boot:spring-boot-starter-actuator:2.1.4.RELEASE",
        sha1 = "3f3897febeecb4c3243e5a31bee769e4d9fd9445",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_freemarker",
        artifact = "org.springframework.boot:spring-boot-starter-freemarker:2.1.4.RELEASE",
        sha1 = "38fb2862111f6c3130b7255dc0d2ece759dc2c45",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_jdbc",
        artifact = "org.springframework.boot:spring-boot-starter-jdbc:2.1.4.RELEASE",
        sha1 = "1e5b6ff541d77655f3295d2f1d66f90f50b58f03",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_jetty",
        artifact = "org.springframework.boot:spring-boot-starter-jetty:2.1.4.RELEASE",
        sha1 = "091a4ce52a1792a35163b0487add255401de59e0",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_logging",
        artifact = "org.springframework.boot:spring-boot-starter-logging:2.2.1.RELEASE",
        sha1 = "8ba18bb64e02782065526e05bdd1ea5622b04b21",
        sha1_src = "df4ea87545b1ca478885ac41188b5fd925f2cca3",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_security",
        artifact = "org.springframework.boot:spring-boot-starter-security:2.1.4.RELEASE",
        sha1 = "07f8755a11498310510c223c1b4d6fb888561f2d",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_test",
        artifact = "org.springframework.boot:spring-boot-starter-test:2.1.4.RELEASE",
        sha1 = "6d19808f14c6d867eef42ea48bf78c37da1d6275",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_web",
        artifact = "org.springframework.boot:spring-boot-starter-web:2.1.4.RELEASE",
        sha1 = "a4659d55f57421a5ef122cb670b7b544ef8190e8",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_test",
        artifact = "org.springframework.boot:spring-boot-test:2.2.1.RELEASE",
        sha1_src = "b097a4aa5d3aaf5ed4ca93605865da1753de4345",
        sha1 = "e7eb297ce594e4b6d5185ab4004e460be4bf8d1a",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_test_autoconfigure",
        artifact = "org.springframework.boot:spring-boot-test-autoconfigure:2.2.1.RELEASE",
        sha1_src = "e873696d41d73a414b2b4d6c208794a00effda92",
        sha1 = "8724bfc256951048700ae2a6b0e62ba068f7e5e2",
    )

    native.maven_jar(
        name = "org_springframework_boot_spring_boot_starter_thymeleaf",
        artifact = "org.springframework.boot:spring-boot-starter-thymeleaf:2.1.4.RELEASE",
        sha1 = "631b7593129c2f8f43df783fc7fd4a0b5edce747",
    )

    native.maven_jar(
        name = "org_springframework_plugin_spring_plugin_core",
        artifact = "org.springframework.plugin:spring-plugin-core:jar:1.2.0.RELEASE",
        sha1 = "f380e7760032e7d929184f8ad8a33716b75c0657",
        sha1_src = "112d82259202fa909d51cf7ccefae0c5523f1373",
    )

    native.maven_jar(
        name = "org_springframework_plugin_spring_plugin_metadata",
        artifact = "org.springframework.plugin:spring-plugin-metadata:jar:1.2.0.RELEASE",
        sha1 = "97223fc496b6cab31602eedbd4202aa4fff0d44f",
        sha1_src = "6551604dd9c0619bae2f5a244580fa9a0dc646bf",
    )

    native.maven_jar(
        name = "org_springframework_retry_spring_retry",
        artifact = "org.springframework.retry:spring-retry:1.2.4.RELEASE",
        sha1 = "e5a1e629b2743dc7bbe4a8d07ebe9ff6c3b816ce",
        sha1_src = "26c0f619ab2af4ad6244e103fac42f327abcabbf",
    )

    native.maven_jar(
        name = "org_springframework_security_spring_security_config",
        artifact = "org.springframework.security:spring-security-config:5.2.1.RELEASE",
        sha1_src = "bbd406c763af685611698c5816eeb6cedcedc000",
        sha1 = "8f49e12035d0357b5f35e254334ea06d4585cf01",
    )

    native.maven_jar(
        name = "org_springframework_security_spring_security_core",
        artifact = "org.springframework.security:spring-security-core:5.2.1.RELEASE",
        sha1_src = "1ffd134e0a23a0564b44616daf401bbc7918275b",
        sha1 = "f1265ecdd4636a2038768c2ab9da4b79961a3465",
    )

    native.maven_jar(
        name = "org_springframework_security_spring_security_web",
        artifact = "org.springframework.security:spring-security-web:5.2.1.RELEASE",
        sha1_src = "44a612127342efee296f5a4c04004e6c0f622899",
        sha1 = "9e43c2d8d2dffc60bfba8ac95a106d30e9593106",
    )

    native.maven_jar(
        name = "org_springframework_spring_aop",
        artifact = "org.springframework:spring-aop:5.2.1.RELEASE",
        sha1 = "34c11ad92e06753e592865c7c403b09ab884d862",
        sha1_src = "37720d061b744366e1e1faf5aa6838df99f3ec47",
    )

    native.maven_jar(
        name = "org_springframework_spring_aspects",
        artifact = "org.springframework:spring-aspects:5.1.6.RELEASE",
        sha1_src = "668bbfa9d2b1c53536904910949b8013a1e57af6",
        sha1 = "c17785ecb504e026dd910facc44127db6317577a",
    )

    native.maven_jar(
        name = "org_springframework_spring_beans",
        artifact = "org.springframework:spring-beans:5.2.1.RELEASE",
        sha1_src = "d2a036b0652391aa91828b00e87f9354822a2e70",
        sha1 = "d05690257d8e8034b180db3893d5baf8250fb9d3",
    )

    native.maven_jar(
        name = "org_springframework_spring_context",
        artifact = "org.springframework:spring-context:5.2.1.RELEASE",
        sha1_src = "43da4e562e25c4c5931e2dec04f2037f9d230391",
        sha1 = "1d3e142adbdbd0810b19462fbd88d94cc51cce01",
    )

    native.maven_jar(
        name = "org_springframework_spring_context_support",
        artifact = "org.springframework:spring-context-support:5.2.1.RELEASE",
        sha1_src = "51bbd8974243c7fd29ee6ec7c3807cdbc5b1be2d",
        sha1 = "22fedda999e1b443be19bc3fb7ec326a6e0caf05",
    )

    native.maven_jar(
        name = "org_springframework_spring_core",
        artifact = "org.springframework:spring-core:5.2.1.RELEASE",
        sha1_src = "55e7202309d932c4d47ccec00500f98425406309",
        sha1 = "32b265ff5c7c35257b5a242b9628dcd321a2b010",
    )

    native.maven_jar(
        name = "org_springframework_spring_expression",
        artifact = "org.springframework:spring-expression:5.2.1.RELEASE",
        sha1_src = "0896e15320e8e21b87e93622d984e0afc52fdb26",
        sha1 = "499e91096320f7e6fcfd6920e66d5ed5f0ecfee9",
    )

    native.maven_jar(
        name = "org_springframework_spring_jdbc",
        artifact = "org.springframework:spring-jdbc:5.2.1.RELEASE",
        sha1_src = "5b790943095dbb4c26a43d00415be88c8e8bbae1",
        sha1 = "b33c907cbaff98fdfe7d8707ce046e595805c795",
    )

    native.maven_jar(
        name = "org_springframework_spring_test",
        artifact = "org.springframework:spring-test:5.2.1.RELEASE",
        sha1 = "939bbeb098b3944f3f5323d6c3703cb9b78f5de2",
        sha1_src = "628dee8555b5010b926ebd880f7b108140520c71",
    )

    native.maven_jar(
        name = "org_springframework_spring_tx",
        artifact = "org.springframework:spring-tx:5.2.1.RELEASE",
        sha1_src = "0e13efee00643e55716f214a22e4f6a8fb8e3817",
        sha1 = "eea31b77780487a188af44d9a1bacf717a68da72",
    )

    native.maven_jar(
        name = "org_springframework_spring_web",
        artifact = "org.springframework:spring-web:5.2.1.RELEASE",
        sha1 = "4f1dfe592951c312b52de469f1940b1cb0455226",
        sha1_src = "5247d73874757aa411626d2bf156360768005dc5",
    )

    native.maven_jar(
        name = "org_springframework_spring_webmvc",
        artifact = "org.springframework:spring-webmvc:5.2.1.RELEASE",
        sha1 = "9c118e3a551fe4bf31eb9e395b5f8ef42cf14f42",
        sha1_src = "3668f11c423b5fa6d442a0282151895dc81959ca",
    )

    native.maven_jar(
        name = "org_yaml_snakeyaml",
        artifact = "org.yaml:snakeyaml:1.25",
    )
