<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math" version="3.0">



    <!--GLOBAL VARIABLES -->
    <xsl:variable name="currentDateTime" as="xs:string" select="current-dateTime() ! string()"/>
    <xsl:variable name="P5" as="document-node()" select="doc('../p5.xml')"/>
    <xsl:variable name="P5-version" as="xs:string" select="$P5//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-versionDate" as="xs:string"
        select="$P5//edition/date/@when ! normalize-space()"/>

    <xsl:variable name="nf:graph-model" as="map(xs:string, map(*))">
        <xsl:map>
            <xsl:map-entry key="'document'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Document</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">document()</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">doc</xsl:map-entry>
                    <xsl:map-entry key="'jsonVar'">value</xsl:map-entry>
                    <!-- ebb: Literally 'value' is the value of the document imported on load into neo4j. -->
                    <xsl:map-entry key="'primaryKey'">title</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOCUMENT_TITLE</xsl:map-entry>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'jsonDateTime'">THIS_JSON_DATETIME</xsl:map-entry>
                            <xsl:map-entry key="'teiSourceDate'">TEI_SOURCE_OUTPUT_DATE</xsl:map-entry>
                            <xsl:map-entry key="'teiSourceVersion'">TEI_SOURCE_VERSION_NUMBER</xsl:map-entry>
                            <xsl:map-entry key="'supportInst'">SUPPORTING_INSTITUTION</xsl:map-entry>
                            <xsl:map-entry key="'byline'">PREPARED_BY</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARTS',
                                        'childEntityType': 'part',
                                        'relationship': 'HAS_PART',
                                        'isSequence': true()
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'part'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Part</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">front | body</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">part</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">PART</xsl:map-entry>
                    <xsl:map-entry key="'properties'">
                        <xsl:map><!-- OUTPUT SEQUENCE VALUES IN JSON-DATA -->
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                            'childEntityType': 'chapter',
                            'relationship': 'HAS_CHAPTER',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'chapter'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Chapter'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div1']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'chapter'"/>
                    <xsl:map-entry key="'primaryKey'" select="'chapter_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">CHAPTER</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'section',
                            'relationship': 'HAS_SECTION',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_1'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_1'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                            'childEntityType': 'section_2',
                            'relationship': 'HAS_SUBSECTION',
                            'isSequence': true()
                            },
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section_2'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_2'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_2'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                            'childEntityType': 'section_3',
                            'relationship': 'HAS_SUBSECTION',
                            'isSequence': true()
                            },
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section_3'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_3'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_3'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO.SECTION'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Para'"/>
                    <xsl:map-entry key="'xpathPattern'">p[*]</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'primaryKey'" select="'parastring'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'PARASTRING'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO.SECTION'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'elements_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ELEMENTS_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ELEMENT_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in an elementSpec? -->
                                </xsl:map>
                            </xsl:map-entry> 
                            <xsl:map-entry key="'attributes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ATTRIBUTES_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ATTRIBUTE_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in a classSpec / attribute definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <!-- idents_mentioned: 11 different JSON keys -->
                            <xsl:map-entry key="'modules_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MODULES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MODULE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'classes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CLASSES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'CLASS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'files_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FILES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FILE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'datatypes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.DATATYPES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'DATATYPE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'macros_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MACROS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MACRO'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'ns_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.NSS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'NS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'schemas_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.SCHEMAS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'SCHEMA'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'PE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned_ge'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'GE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'frags_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FRAGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FRAG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'relaxng_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.RNGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'RNG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'speclist_links'">
                                <!-- ebb: We were not processing these before, but I experimented with something similar in my xslt Sandbox.
                                <specList> elements contain just one kind of element child: <specDesc>
                                The <specList> can be children of <p>, or descendants of <p> (within a list[@type='gloss']/item)
                                The <specDesc> children have a @key that points to the ID of a spec, like so:
                                <specList>
                                      <specDesc key="correction" atts="status method"/>
                                </specList>
                                -->
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CONTAINS_SPECLISTS.SPECLIST'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            (: COMMENTED OUT B/C LIST COMPREHENSION IN PROPERTIES  map {
                            'jsonChildrenKey': 'CONTAINS_SPECLISTS',
                            'childEntityType': 'speclist',
                            'relationship': 'HAS_SPECLIST'
                            },:)
                            map{ 
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_EXAMPLES',
                            'childEntityType': 'example',
                            'relationship': 'HAS_EXAMPLE'
                            },
                            map {
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_SPECGRPS',
                            'childEntityType': 'specgrp',
                            'relationship': 'HAS_SPECGRP'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'example'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Example'"/>
                    <xsl:map-entry key="'xpathPattern'">eg:egXML</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'example'"/>
                    <xsl:map-entry key="'primaryKey'" select="'example'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'EXAMPLE'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'language'">LANGUAGE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            
                            }"/>   
                    </xsl:map-entry>
                </xsl:map>  
            </xsl:map-entry>
            <xsl:map-entry key="'specgrp'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Specgrp'"/>
                    <xsl:map-entry key="'xpathPattern'">specGrp</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                    <xsl:map-entry key="'primaryKey'" select="'specgrp_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPECGRP_ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'name'">SPECGRP_NAME</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                            </xsl:map>
                        </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{
                            map{
                                'jsonChildrenKey': 'CONTAINS_SPECS',
                                'childEntityType': 'spec',
                                'relationship': 'HAS_SPEC'
                            }
                            }"/>
                    </xsl:map-entry>                
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'spec'">
                <xsl:map-entry key="'label'" select="'Spec'"/>
                <xsl:map-entry key="'xpathPattern'">specGrp</xsl:map-entry>
                <xsl:map-entry key="'cypherVar'" select="'spec'"/>
                <xsl:map-entry key="'primaryKey'" select="'spec_id'"/>
                <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC_ID'"/>
                <xsl:map-entry key="'properties'">
                    <xsl:map>
                        <xsl:map-entry key="'spec_type'">SPEC_TYPE</xsl:map-entry>
                        <xsl:map-entry key="'module'">PART_OF_MODULE</xsl:map-entry>
                        <xsl:map-entry key="'class'">MEMBER_OF_CLASS</xsl:map-entry>
                        <xsl:map-entry key="'equiv_name'">EQUIVALENT_NAME</xsl:map-entry>
                        <xsl:map-entry key="'glosses'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'GLOSSED_BY'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'GLOSS'"/>
                            </xsl:map>
                        </xsl:map-entry>
                        <xsl:map-entry key="'descriptions'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'DESCRIBED_BY'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'DESC'"/>
                            </xsl:map>
                        </xsl:map-entry>
                        <xsl:map-entry key="'remarks'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'REMARKS_ON'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'REMARK'"/>
                            </xsl:map>
                        </xsl:map-entry>
                    </xsl:map>
                </xsl:map-entry>
                <xsl:map-entry key="'children'">
                    <xsl:sequence select="array{ 
                        map{ 
                        'jsonChildrenKey': 'CONTAINS_CONTENT_MODEL',
                        'childEntityType': 'content_model',
                        'relationship': 'CONTENT_MODEL'
                         },
                         map{ 
                         'jsonChildrenKey': 'LISTS_ATTRIBUTES',
                         'childEntityType': 'attribute',
                         'relationship': 'HAS_ATTRIBUTE'
                         },
                         map{ 
                         'jsonChildrenKey': 'CONSTRAINED_BY',
                         'childEntityType': 'constraint',
                         'relationship': 'HAS_CONSTRAINT'
                         },
                         map{ 
                         'jsonChildrenKey': 'CONTAINS_EXAMPLES',
                         'childEntityType': 'example',
                         'relationship': 'HAS_EXAMPLE'
                         } 
                        }"/>
                </xsl:map-entry>                  
            </xsl:map-entry>
            <xsl:map-entry key="'content_model'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Contentmodel'"/>
                    <xsl:map-entry key="'xpathPattern'">content</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'content_model'"/>
                    <xsl:map-entry key="'primaryKey'" select="'spec_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC_ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'textnode'">TEXTNODE</xsl:map-entry>
                            <xsl:map-entry key="'empty'">EMPTY</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_ALTERNATING_CONTENTS',
                            'childEntityType' : 'alternate',
                            'relationship' : 'ALTERNATING'
                            },
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_SEQUENTIAL_CONTENTS',
                            'childEntityType' : 'sequence',
                            'relationship' : 'SEQUENCE',
                            'isSequence': true()
                            },
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_VALLIST',
                            'childEntityType' : 'vallist',
                            'relationship' : 'HAS_VAL'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_DATAREF',
                            'childEntityType': 'dataref',
                            'relationship': 'HAS_DATAREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_MACROREF',
                            'childEntityType': 'macroref',
                            'relationship': 'HAS_MACROREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_CLASSREF',
                            'childEntityType': 'classref',
                            'relationship': 'HAS_CLASSREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_ELEMENTREF',
                            'childEntityType': 'elementref',
                            'relationship': 'HAS_ELEMENTREF'
                            }
                            }"/>
                    </xsl:map-entry>
                    
                    
                    
                    
                </xsl:map> 
            </xsl:map-entry>
        </xsl:map>
    </xsl:variable>



    <!-- JSON MAPPING TO KEYS -->
    <!-- GRAPH NODE KEYS -->
    <xsl:variable name="DOCUMENT_TITLE" as="xs:string" select="'DOCUMENT_TITLE'"/>
    <xsl:variable name="PREPARED_BY" as="xs:string" select="'PREPARED_BY'"/>
    <xsl:variable name="SUPPORTING_INSTITUTION" as="xs:string" select="'SUPPORTING_INSTITUTION'"/>
    <xsl:variable name="TEI_SOURCE_VERSION_NUMBER" as="xs:string"
        select="'TEI_SOURCE_VERSION_NUMBER'"/>
    <xsl:variable name="TEI_SOURCE_OUTPUT_DATE" as="xs:string" select="'TEI_SOURCE_OUTPUT_DATE'"/>
    <xsl:variable name="THIS_JSON_DATETIME" as="xs:string" select="'THIS_JSON_DATETIME'"/>
    <xsl:variable name="PART" as="xs:string" select="'PART'"/>
    <xsl:variable name="CHAPTER" as="xs:string" select="'CHAPTER'"/>
    <xsl:variable name="SUBSECTION" as="xs:string" select="'SUBSECTION'"/>
    <xsl:variable name="NAME" as="xs:string" select="'NAME'"/>
    <xsl:variable name="ID" as="xs:string" select="'ID'"/>

    <!-- SEQUENCE INDICATORS -->
    <xsl:variable name="CONTAINS_PARTS" as="xs:string" select="'CONTAINS_PARTS'"/>
    <xsl:variable name="CONTAINS_CHAPTERS" as="xs:string" select="'CONTAINS_CHAPTERS'"/>
    <xsl:variable name="CONTAINS_SECTIONS" as="xs:string" select="'CONTAINS_SECTIONS'"/>
    <xsl:variable name="CONTAINS_SUBSECTIONS" as="xs:string" select="'CONTAINS_SUBSECTIONS'"/>
    <xsl:variable name="CONTAINS_PARAS" as="xs:string" select="'CONTAINS_PARAS'"/>




    <!-- JSON-DATA functions -->
    <!-- ebb: An accumulator function suggested on the XML Slack for numbering, in case we want it. Not sure we need it? -->
    <xsl:function name="nf:mapToArray" as="array(*)*">
        <xsl:param name="sourceMap" as="map(*)"/>
        <xsl:sequence select="
                fold-left(1 to map:size($sourceMap), [], function ($acc as array(*), $index as xs:integer)
                {
                    array:append($acc, $sourceMap($index))
                })"/>

    </xsl:function>
    <xsl:function name="nf:chapterMapper" as="map(*)*">
        <xsl:param name="part" as="element()+"/>
        <xsl:for-each select="$part">
            <xsl:map>
                <xsl:map-entry key="$PART">
                    <xsl:sequence select="current() ! name() ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:variable name="chapterMaps" as="map(*)*">
                    <xsl:for-each
                        select="current()/div[not(@xml:id = 'DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))]">
                        <xsl:variable name="chap" as="element(div)" select="current()"/>
                        <xsl:map>
                            <xsl:map-entry key="$CHAPTER">
                                <xsl:value-of select="$chap/head ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="$ID">
                                <xsl:value-of select="$chap/@xml:id ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="'SEQUENCE'">
                                <xsl:value-of select="count($chap/preceding-sibling::*) + 1"/>
                            </xsl:map-entry>


                            <!--   <xsl:if test="current()[p]">
                                        <xsl:map-entry key="$CONTAINS_PARAS"><xsl:sequence select="array{nf:paraPuller(current()/p) }"/></xsl:map-entry>
                                    </xsl:if>-->
                        </xsl:map>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:map-entry key="$CONTAINS_CHAPTERS">
                    <xsl:sequence select="array {$chapterMaps}"/>
                </xsl:map-entry>
            </xsl:map>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="nf:DivPuller" as="map(*)*">
        <xsl:param name="div" as="element()"/>
        <xsl:param name="sectionLevel" as="xs:string"/>
        <xsl:map>
            <xsl:map-entry key="$NAME">
                <xsl:value-of select="$div/head ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:map-entry key="$ID">
                <xsl:value-of select="$div/@xml:id ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:map-entry key="'SEQUENCE'">
                <xsl:value-of select="count($div/preceding-sibling::div + 1)"/>
            </xsl:map-entry>

            <!-- Are you a section with nested subsections? If so, continue processing those subsections. -->
            <xsl:if test="$div/div[head]">
                <xsl:map-entry key="'CONTAINS-' || $sectionLevel || 'S'">

                    <xsl:sequence select="
                            array {
                                for $subd in $div/div[head]
                                return
                                    nf:DivPuller($subd, 'SECTION')
                            }"/>
                </xsl:map-entry>
            </xsl:if>

        </xsl:map>
    </xsl:function>

    <!--    <xsl:template match="/" mode="json-schema">
        <xsl:result-document href="../digitai-RAG-json.schema">
            
            
            
        </xsl:result-document>
    </xsl:template>-->

    <xsl:template match="/" mode="cypher">
        <xsl:result-document href="../digitai-RAG-cypher.cypher" method="text" indent="yes"> CALL
            apoc.load.json("file:///digitai-RAG-data.json") YIELD value AS json_data
            <!-- Create the document node --> MERGE (doc:Document { title: json_data.<xsl:value-of
                select="$DOCUMENT_TITLE"/>, preparedBy: json_data.<xsl:value-of
                select="$PREPARED_BY"/>, teiSourceVersion: json_data.<xsl:value-of
                select="$TEI_SOURCE_VERSION_NUMBER"/>, teiSourceOutputDate: json_data.<xsl:value-of
                select="$TEI_SOURCE_OUTPUT_DATE"/>, thisJsonDatetime: json_data.<xsl:value-of
                select="$THIS_JSON_DATETIME"/>
            <!-- Create the Part nodes --> FOREACH (<xsl:value-of select="$PART"/>_data IN
                json_data.<xsl:value-of select="$CONTAINS_PARTS"/> | MERGE (part:Part {name:
                data.<xsl:value-of select="$PART"/>) MERGE (doc)-[:CONTAINS_PART]->(part)
            <!-- Go through the CONTAINS_CHAPTERS array to create Chapter nodes --> FOREACH
                (<xsl:value-of select="$CHAPTER"/>_data IN json_data.<xsl:value-of
                select="$CONTAINS_CHAPTERS"/> | MERGE (chapter:Chapter {id: chapter_data.ID}) ON
            CREATE SET chapter.chapter = chapter_data.CHAPTER
            <!-- CONNECT ELEMENTS and ATTRIBUTES MENTIONED to their SPECS -->
        </xsl:result-document>
    </xsl:template>


    <xsl:template match="/">
        <xsl:result-document href="../digitai-RAG-data.json" method="json" indent="yes">
            <xsl:map>
                <xsl:map-entry key="$DOCUMENT_TITLE">THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE
                    GRAPH</xsl:map-entry>
                <xsl:map-entry key="$PREPARED_BY">Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae
                    Bills, and Alexander Charles Fisher</xsl:map-entry>
                <xsl:map-entry key="$SUPPORTING_INSTITUTION">Penn State Erie, The Behrend
                    College</xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_VERSION_NUMBER">
                    <xsl:value-of select="$P5-version"/>
                </xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_OUTPUT_DATE">
                    <xsl:value-of select="$P5-versionDate"/>
                </xsl:map-entry>
                <xsl:map-entry key="$THIS_JSON_DATETIME">
                    <xsl:value-of select="$currentDateTime"/>
                </xsl:map-entry>
                <xsl:map-entry key="$CONTAINS_PARTS">
                    <xsl:sequence select="array {nf:chapterMapper($P5/TEI/text/*[not(self::back)])}"
                    />
                </xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
        <xsl:apply-templates select="/" mode="cypher"/>
    </xsl:template>

</xsl:stylesheet>
